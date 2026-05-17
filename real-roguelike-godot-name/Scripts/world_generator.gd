extends Node

# Layers
@onready var ground_layer = $"../Ground"
@onready var decorations_layer = $"../Decorations"
@onready var structures_layer = $"../Structures"
@onready var obstacles_layer = $"../Obstacles"

const MIN_BIOME_SIZE = 50

# Noise
var temp_noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()

# Mob Spawning
const CLUSTER_COUNT = 400
const MIN_SPAWN_DIST = 5

# Ground Tiles
const TILE_GRASS = Vector2i(0, 0)
const TILE_SAND  = Vector2i(0, 4)
const TILE_SNOW  = Vector2i(3, 4)

# Decoration Tiles
const DECO_FLOWER = Vector2i(4, 3)

# VOID1 — border on one side
const DECO_VOID1_R0   = Vector2i(1, 0)
const DECO_VOID1_R90  = Vector2i(2, 0)
const DECO_VOID1_R180 = Vector2i(3, 0)
const DECO_VOID1_R270 = Vector2i(4, 0)

# VOID2 — border on two adjacent sides (corner)
const DECO_VOID2_R0   = Vector2i(3, 1)
const DECO_VOID2_R90  = Vector2i(0, 1)
const DECO_VOID2_R180 = Vector2i(1, 1)
const DECO_VOID2_R270 = Vector2i(2, 1)

# VOID2_ALT — border on two opposite sides (stripe)
const DECO_VOID2_ALT_R0   = Vector2i(4, 1)
const DECO_VOID2_ALT_R90  = Vector2i(0, 2)
const DECO_VOID2_ALT_R180 = Vector2i(1, 2)
const DECO_VOID2_ALT_R270 = Vector2i(2, 2)

# VOID3 — border on three sides
const DECO_VOID3_R0   = Vector2i(3, 2)
const DECO_VOID3_R90  = Vector2i(4, 2)
const DECO_VOID3_R180 = Vector2i(0, 3)
const DECO_VOID3_R270 = Vector2i(1, 3)

# Obstacle Tiles
const OBST_TREE = Vector2i(2, 3)
const OBST_ROCK = Vector2i(3, 3)
const OBST_PALM = Vector2i(2, 4)
const OBST_ICE  = Vector2i(0, 5)

# Structures
const STRUCTURE_COUNT = 8
const MIN_STRUCTURE_DIST = 30
var placed_positions = []
var structure_coords = {}

const STRUCTURE_CHURCH = {
	"source_id": 1,
	"size": Vector2i(8, 8),
	"tiles": [
		[Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0), Vector2i(5,0), Vector2i(6,0), Vector2i(7,0)],
		[Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(3,1), Vector2i(4,1), Vector2i(5,1), Vector2i(6,1), Vector2i(7,1)],
		[Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2), Vector2i(4,2), Vector2i(5,2), Vector2i(6,2), Vector2i(7,2)],
		[Vector2i(0,3), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3), Vector2i(4,3), Vector2i(5,3), Vector2i(6,3), Vector2i(7,3)],
		[Vector2i(0,4), Vector2i(1,4), Vector2i(2,4), Vector2i(3,4), Vector2i(4,4), Vector2i(5,4), Vector2i(6,4), Vector2i(7,4)],
		[Vector2i(0,5), Vector2i(1,5), Vector2i(2,5), Vector2i(3,5), Vector2i(4,5), Vector2i(5,5), Vector2i(6,5), Vector2i(7,5)],
		[Vector2i(0,6), Vector2i(1,6), Vector2i(2,6), Vector2i(3,6), Vector2i(4,6), Vector2i(5,6), Vector2i(6,6), Vector2i(7,6)],
		[Vector2i(0,7), Vector2i(1,7), Vector2i(2,7), Vector2i(3,7), Vector2i(4,7), Vector2i(5,7), Vector2i(6,7), Vector2i(7,7)],
	]
}

const BIOME_STRUCTURES = {
	TILE_GRASS: STRUCTURE_CHURCH
}

const SOURCE_ID = 0

# Coordinate helpers — half extents
var HW: int
var HH: int

var tile_map = {}


func _ready() -> void:
	HW = Globals.WORLD_WIDTH / 2
	HH = Globals.WORLD_HEIGHT / 2
	setup_noise()
	generate_ground()
	place_structures()
	place_decorations()
	place_obstacles()
	place_borders()
	generate_borders()
	place_enemies()


func setup_noise():
	temp_noise.seed = randi()
	temp_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	temp_noise.frequency = 0.01

	moisture_noise.seed = temp_noise.seed + 9999
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	moisture_noise.frequency = 0.01


func get_ground_tile(t: float, m: float) -> Vector2i:
	if t < 0.0:
		return TILE_SNOW
	elif m < 0.0:
		return TILE_SAND
	else:
		return TILE_GRASS


func generate_ground():
	# All tile_map keys are now in shifted (world) space: -HW to HW
	for x in range(-HW, HW):
		for y in range(-HH, HH):
			var t = temp_noise.get_noise_2d(x, y)
			var m = moisture_noise.get_noise_2d(x, y)
			tile_map[Vector2i(x, y)] = get_ground_tile(t, m)

	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	remove_small_regions()

	# Coordinates are already in world space so pass directly to set_cell
	for coord in tile_map:
		ground_layer.set_cell(coord, SOURCE_ID, tile_map[coord])


func smooth_biomes():
	var new_map = tile_map.duplicate()
	for coord in tile_map:
		var neighbors = get_neighbor_counts(coord)
		var dominant = get_dominant_tile(neighbors)
		if neighbors.get(dominant, 0) >= 4:
			new_map[coord] = dominant
	tile_map = new_map


func get_neighbor_counts(coord: Vector2i) -> Dictionary:
	var counts = {}
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var neighbor = coord + Vector2i(dx, dy)
			if tile_map.has(neighbor):
				var tile = tile_map[neighbor]
				counts[tile] = counts.get(tile, 0) + 1
	return counts


func get_dominant_tile(counts: Dictionary) -> Vector2i:
	var best_tile = TILE_GRASS
	var best_count = 0
	for tile in counts:
		if counts[tile] > best_count:
			best_count = counts[tile]
			best_tile = tile
	return best_tile


func get_foreign_dirs(coord: Vector2i) -> Array:
	var current_biome = tile_map[coord]
	var foreign = []
	for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var neighbor = coord + dir
		if tile_map.has(neighbor) and tile_map[neighbor] != current_biome:
			foreign.append(dir)
	return foreign


func remove_small_regions():
	var visited = {}

	for coord in tile_map:
		if visited.has(coord):
			continue

		var region = []
		var queue = [coord]
		var biome = tile_map[coord]

		while queue.size() > 0:
			var current = queue.pop_front()
			if visited.has(current):
				continue
			if not tile_map.has(current):
				continue
			if tile_map[current] != biome:
				continue
			visited[current] = true
			region.append(current)
			queue.append(current + Vector2i(1, 0))
			queue.append(current + Vector2i(-1, 0))
			queue.append(current + Vector2i(0, 1))
			queue.append(current + Vector2i(0, -1))

		if region.size() < MIN_BIOME_SIZE:
			var neighbor_counts = {}
			for cell in region:
				for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var neighbor = cell + dir
					if tile_map.has(neighbor) and tile_map[neighbor] != biome:
						var n_biome = tile_map[neighbor]
						neighbor_counts[n_biome] = neighbor_counts.get(n_biome, 0) + 1
			var replacement = get_dominant_tile(neighbor_counts)
			for cell in region:
				tile_map[cell] = replacement


func place_structures():
	for biome in BIOME_STRUCTURES:
		var structure = BIOME_STRUCTURES[biome]
		var placed = 0
		var attempts = 0
		var rows = structure.size.y
		var cols = structure.size.x

		while placed < STRUCTURE_COUNT and attempts < STRUCTURE_COUNT * 100:
			attempts += 1

			var cx = randi_range(-HW + cols + 5, HW - cols - 5)
			var cy = randi_range(-HH + rows + 5, HH - rows - 5)
			var coord = Vector2i(cx, cy)

			# Make sure the coord exists in tile_map
			if not tile_map.has(coord):
				continue

			# Make sure the center tile is actually the right biome
			if tile_map[coord] != biome:
				continue

			if not can_place_structure(cx, cy, biome, structure):
				continue

			var too_close = false
			for pos in placed_positions:
				if Vector2(cx, cy).distance_to(Vector2(pos.x + cols/2, pos.y + cols/2)) < MIN_STRUCTURE_DIST:
					too_close = true
					break
			if too_close:
				continue

			create_structure(cx, cy, structure)
			print(str(cx) + ", " + str(cy))
			place_structure_enemies(cx, cy, structure)
			placed_positions.append(Vector2i(cx, cy))
			placed += 1


func can_place_structure(cx: int, cy: int, biome: Vector2i, structure: Dictionary) -> bool:
	var rows = structure.size.y
	var cols = structure.size.x

	for dy in range(-3, rows + 3):
		for dx in range(-3, cols + 3):
			if dy >= 0 and dy < rows and dx >= 0 and dx < cols:
				if structure.tiles[dy][dx] == null:
					continue
			var coord = Vector2i(cx + dx, cy + dy)
			if not tile_map.has(coord):
				return false
			if tile_map[coord] != biome:
				return false
	return true


func create_structure(cx: int, cy: int, structure: Dictionary):
	var center = Vector2i(cx + structure.size.x / 2, cy + structure.size.y / 2)
	for dy in structure.size.y:
		for dx in structure.size.x:
			var tile = structure.tiles[dy][dx]
			if tile != null:
				var coord = Vector2i(cx + dx, cy + dy)
				structures_layer.set_cell(coord, structure.source_id, tile)
				structure_coords[coord] = true


func place_structure_enemies(cx: int, cy: int, structure: Dictionary):
	var rows = structure.size.y
	var cols = structure.size.x
	var center_x = cx + cols / 2
	var center_y = cy + rows / 2

	var biome = tile_map[Vector2i(cx, cy)]
	if not Globals.BIOME_ENEMIES.has(biome):
		return

	var enemy_scene = load(Globals.BIOME_ENEMIES[biome])

	for i in 6:
		var angle = (TAU / 6) * i
		var radius = max(rows, cols) + 2
		var ex = int(center_x + cos(angle) * radius)
		var ey = int(center_y + sin(angle) * radius)
		var spawn_coord = Vector2i(ex, ey)

		if not tile_map.has(spawn_coord):
			continue
		if tile_map[spawn_coord] != biome:
			continue

		var enemy = enemy_scene.instantiate()
		enemy.position = Vector2(ex, ey) * Globals.TILE_SIZE + Vector2(Globals.TILE_SIZE / 2, Globals.TILE_SIZE / 2)
		get_parent().add_child.call_deferred(enemy)


func place_decorations():
	for coord in tile_map:
		var biome = tile_map[coord]

		if get_foreign_dirs(coord).size() > 0:
			continue
		
		if structure_coords.has(coord):
			continue

		if biome == TILE_GRASS:
			if randf() < 0.05:
				decorations_layer.set_cell(coord, SOURCE_ID, DECO_FLOWER)


func place_obstacles():
	for coord in tile_map:
		var biome = tile_map[coord]

		if get_foreign_dirs(coord).size() > 0:
			continue
		
		if structure_coords.has(coord):
			continue

		var roll = randf()
		if biome == TILE_SNOW:
			if roll < 0.075:
				obstacles_layer.set_cell(coord, SOURCE_ID, OBST_ICE)
		elif biome == TILE_SAND:
			if roll < 0.05:
				obstacles_layer.set_cell(coord, SOURCE_ID, OBST_PALM)
		elif biome == TILE_GRASS:
			if roll < 0.05:
				obstacles_layer.set_cell(coord, SOURCE_ID, OBST_ROCK)
			elif roll < 0.10:
				obstacles_layer.set_cell(coord, SOURCE_ID, OBST_TREE)


func place_enemies():
	var clusters_placed = 0
	var attempts = 0
	var max_attempts = CLUSTER_COUNT * 50
	var max_possible_dist = Vector2(HW, HH).length()

	while clusters_placed < CLUSTER_COUNT and attempts < max_attempts:
		attempts += 1

		var t = pow(randf(), 0.5)
		var angle = randf() * TAU
		var dist_from_center = t * max_possible_dist
		var cx = int(cos(angle) * dist_from_center)
		var cy = int(sin(angle) * dist_from_center)
		cx = clamp(cx, -HW, HW - 1)
		cy = clamp(cy, -HH, HH - 1)
		var coord = Vector2i(cx, cy)

		var dist = Vector2(cx, cy).length()

		if dist < MIN_SPAWN_DIST:
			continue
		if not tile_map.has(coord):
			continue
		if get_foreign_dirs(coord).size() > 0:
			continue

		var biome = tile_map[coord]
		if not Globals.BIOME_ENEMIES.has(biome):
			continue

		var t_scale = clamp(dist / max_possible_dist, 0.0, 1.0)
		var radius = int(lerp(2.0, 6.0, t_scale))
		var enemy_count = int(lerp(2.0, 8.0, t_scale))

		var scene_path = Globals.BIOME_ENEMIES[biome]
		var enemy_scene = load(scene_path)

		for i in enemy_count:
			var offset_x = randi_range(-radius, radius)
			var offset_y = randi_range(-radius, radius)
			var spawn_coord = Vector2i(cx + offset_x, cy + offset_y)

			if not tile_map.has(spawn_coord):
				continue
			if tile_map[spawn_coord] != biome:
				continue
			if get_foreign_dirs(spawn_coord).size() > 0:
				continue

			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(spawn_coord) * Globals.TILE_SIZE + Vector2(Globals.TILE_SIZE / 2, Globals.TILE_SIZE / 2)
			get_parent().add_child.call_deferred(enemy)

		clusters_placed += 1


func generate_borders():
	var width = Globals.WORLD_WIDTH * Globals.TILE_SIZE
	var height = Globals.WORLD_HEIGHT * Globals.TILE_SIZE
	var thickness = Globals.TILE_SIZE * 2

	var walls = [
		[Vector2(0, -height - thickness / 2), width * 2 + thickness * 2, thickness],
		[Vector2(0,  height + thickness / 2), width * 2 + thickness * 2, thickness],
		[Vector2(-width - thickness / 2, 0),  thickness, height * 2],
		[Vector2( width + thickness / 2, 0),  thickness, height * 2],
	]

	for wall in walls:
		var body = StaticBody2D.new()
		body.position = wall[0]
		body.collision_layer = 1
		body.collision_mask = 0

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(wall[1], wall[2])
		shape.shape = rect

		body.add_child(shape)
		get_parent().add_child.call_deferred(body)


func place_borders():
	for coord in tile_map:
		var foreign = get_foreign_dirs(coord)
		match foreign.size():
			1: place_void1(coord, foreign)
			2: place_void2(coord, foreign)
			3: place_void3(coord, foreign)


func place_void1(cell: Vector2i, foreign: Array):
	var dir = foreign[0]
	if dir == Vector2i(0, -1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID1_R0)
	elif dir == Vector2i(1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID1_R90)
	elif dir == Vector2i(0, 1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID1_R180)
	elif dir == Vector2i(-1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID1_R270)


func place_void2(cell: Vector2i, foreign: Array):
	var a = foreign[0]
	var b = foreign[1]

	if (a == Vector2i(0, -1) and b == Vector2i(0, 1)) or \
	   (a == Vector2i(0, 1)  and b == Vector2i(0, -1)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT_R90)
		return
	if (a == Vector2i(1, 0)  and b == Vector2i(-1, 0)) or \
	   (a == Vector2i(-1, 0) and b == Vector2i(1, 0)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT_R0)
		return

	var pair = [a, b]
	if pair.has(Vector2i(0, -1)) and pair.has(Vector2i(1, 0)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_R0)
	elif pair.has(Vector2i(1, 0)) and pair.has(Vector2i(0, 1)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_R90)
	elif pair.has(Vector2i(0, 1)) and pair.has(Vector2i(-1, 0)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_R180)
	elif pair.has(Vector2i(-1, 0)) and pair.has(Vector2i(0, -1)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_R270)


func place_void3(cell: Vector2i, foreign: Array):
	var all_dirs = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	var clear_dir = Vector2i(0, 0)
	for dir in all_dirs:
		if not foreign.has(dir):
			clear_dir = dir
			break

	if clear_dir == Vector2i(0, 1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R0)
	elif clear_dir == Vector2i(-1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R90)
	elif clear_dir == Vector2i(0, -1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R180)
	elif clear_dir == Vector2i(1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R270)
