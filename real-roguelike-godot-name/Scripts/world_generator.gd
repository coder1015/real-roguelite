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

# Mob Spwaning
const CLUSTER_COUNT = 400       # how many clusters across the whole map
const CLUSTER_RADIUS = 3       # how many tiles wide each cluster is
const MIN_SPAWN_DIST = 5      # minimum tiles away from world center (0,0) to spawn

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
const MIN_STRUCTURE_DIST = 100

const STRUCTURE_CHURCH = {
	"source_id": 1,
	"size": Vector2i(16, 16),
	"tiles": [
		[null         ,  null         ,  null         ,  null         ,  null         ,  Vector2i(5,0),  Vector2i(6,0),  Vector2i(7,0),  Vector2i(8,0),  Vector2i(9,0),  Vector2i(10,0), null          , null          , null          , null          , null          ],
		[null         ,  null         ,  null         ,  null         ,  Vector2i(4,1),  Vector2i(5,1),  Vector2i(6,1),  Vector2i(7,1),  Vector2i(8,1),  Vector2i(9,1),  Vector2i(10,1), Vector2i(11,1), null          , null          , null          , null          ],
		[null         ,  null         ,  null         ,  null         ,  Vector2i(4,2),  Vector2i(5,2),  Vector2i(6,2),  Vector2i(7,2),  Vector2i(8,2),  Vector2i(9,2),  Vector2i(10,2), Vector2i(11,2), null          , null          , null          , null          ],
		[null         ,  null         ,  null         ,  null         ,  Vector2i(4,3),  Vector2i(5,3),  Vector2i(6,3),  Vector2i(7,3),  Vector2i(8,3),  Vector2i(9,3),  Vector2i(10,3), Vector2i(11,3), null          , null          , null          , null          ],
		[null         ,  null         ,  null         ,  null         ,  Vector2i(4,4),  Vector2i(5,4),  Vector2i(6,4),  Vector2i(7,4),  Vector2i(8,4),  Vector2i(9,4),  Vector2i(10,4), Vector2i(11,4), null          , null          , null          , null          ],
		[null         ,  null         ,  null         ,  null         ,  Vector2i(4,5),  Vector2i(5,5),  Vector2i(6,5),  Vector2i(7,5),  Vector2i(8,5),  Vector2i(9,5),  Vector2i(10,5), Vector2i(11,5), null          , null          , null          , null          ],
		[Vector2i(0,6),  Vector2i(1,6),  Vector2i(2,6),  Vector2i(3,6),  Vector2i(4,6),  Vector2i(5,6),  Vector2i(6,6),  Vector2i(7,6),  Vector2i(8,6),  Vector2i(9,6),  Vector2i(10,6), Vector2i(11,6), Vector2i(12,6), Vector2i(13,6), Vector2i(14,6), Vector2i(15,6)],
		[Vector2i(0,7),  Vector2i(1,7),  Vector2i(2,7),  Vector2i(3,7),  Vector2i(4,7),  Vector2i(5,7),  Vector2i(6,7),  Vector2i(7,7),  Vector2i(8,7),  Vector2i(9,7),  Vector2i(10,7), Vector2i(11,7), Vector2i(12,7), Vector2i(13,7), Vector2i(14,7), Vector2i(15,7)],
		[Vector2i(0,8),  Vector2i(1,8),  Vector2i(2,8),  Vector2i(3,8),  Vector2i(4,8),  Vector2i(5,8),  Vector2i(6,8),  Vector2i(7,8),  Vector2i(8,8),  Vector2i(9,8),  Vector2i(10,8), Vector2i(11,8), Vector2i(12,8), Vector2i(13,8), Vector2i(14,8), Vector2i(15,8)],
		[Vector2i(0,9),  Vector2i(1,9),  Vector2i(2,9),  Vector2i(3,9),  Vector2i(4,9),  Vector2i(5,9),  Vector2i(6,9),  Vector2i(7,9),  Vector2i(8,9),  Vector2i(9,9),  Vector2i(10,9), Vector2i(11,9), Vector2i(12,9), Vector2i(13,9), Vector2i(14,9), Vector2i(15,9)],
		[null          , null          , null          , null          , Vector2i(4,10), Vector2i(5,10), Vector2i(6,10), Vector2i(7,10), Vector2i(8,10), Vector2i(9,10), Vector2i(10,10),Vector2i(11,10), null          , null          , null          , null          ],
		[null          , null          , null          , null          , Vector2i(4,11), Vector2i(5,11), Vector2i(6,11), Vector2i(7,11), Vector2i(8,11), Vector2i(9,11), Vector2i(10,11),Vector2i(11,11), null          , null          , null          , null          ],
		[null          , null          , null          , null          , Vector2i(4,12), Vector2i(5,12), Vector2i(6,12), Vector2i(7,12), Vector2i(8,12), Vector2i(9,12), Vector2i(10,12),Vector2i(11,12), null          , null          , null          , null          ],
		[null          , null          , null          , null          , Vector2i(4,13), Vector2i(5,13), Vector2i(6,13), Vector2i(7,13), Vector2i(8,13), Vector2i(9,13), Vector2i(10,13),Vector2i(11,13), null          , null          , null          , null          ],
		[null          , null          , null          , null          , Vector2i(4,14), Vector2i(5,14), Vector2i(6,14), Vector2i(7,14), Vector2i(8,14), Vector2i(9,14), Vector2i(10,14),Vector2i(11,14), null          , null          , null          , null          ],
		[null          , null          , null          , null          , Vector2i(4,15), Vector2i(5,15), Vector2i(6,15), Vector2i(7,15), Vector2i(8,15), Vector2i(9,15), Vector2i(10,15),Vector2i(11,15), null          , null          , null          , null          ],
	]
}

const BIOME_STRUCTURES = {
	TILE_GRASS: STRUCTURE_CHURCH
}

const SOURCE_ID = 0

var tile_map = {}


func _ready() -> void:
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
	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var t = temp_noise.get_noise_2d(x, y)
			var m = moisture_noise.get_noise_2d(x, y)
			tile_map[Vector2i(x, y)] = get_ground_tile(t, m)

	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	remove_small_regions()

	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			ground_layer.set_cell(
				Vector2i(x - Globals.WORLD_WIDTH / 2, y - Globals.WORLD_HEIGHT / 2),
				SOURCE_ID,
				tile_map[Vector2i(x, y)]
			)


func smooth_biomes():
	var new_map = tile_map.duplicate()
	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var coord = Vector2i(x, y)
			var neighbors = get_neighbor_counts(x, y)
			var dominant = get_dominant_tile(neighbors)
			if neighbors.get(dominant, 0) >= 4:
				new_map[coord] = dominant
	tile_map = new_map


func place_structures():
	var placed_positions = []
	
	for biome in BIOME_STRUCTURES:
		var structure = BIOME_STRUCTURES[biome]
		var placed = 0
		var attempts = 0
		var rows = structure.size.y
		var cols = structure.size.x
		
		while placed < STRUCTURE_COUNT and attempts < STRUCTURE_COUNT * 20:
			attempts += 1
			
			# Keep the random range within the map
			var cx = randi_range(cols, Globals.WORLD_WIDTH - cols - 1)
			var cy = randi_range(rows, Globals.WORLD_HEIGHT - rows - 1)
			
			if not can_place_structure(cx, cy, biome, structure):
				continue
			
			# Check distance from all previously placed structures
			var too_close = false
			for pos in placed_positions:
				if Vector2(cx, cy).distance_to(Vector2(pos.x, pos.y)) < MIN_STRUCTURE_DIST:
					too_close = true
					break
				if too_close:
					continue
					
			create_structure(cx, cy, structure)
			place_structure_enemies(cx, cy, structure)
			placed_positions.append(Vector2i(cx, cy))
			placed += 1


func can_place_structure(cx: int, cy: int, biome: Vector2i, structure: Dictionary) -> bool:
	var rows = structure.size.y
	var cols = structure.size.x
	
	# Check every tile the structure would occupy plus a 1 tile border around it
	for dy in range(-1, rows + 1):
		for dx in range(-1, cols + 1):
			var coord = Vector2i(cx + dx, cy + dy)
			if not tile_map.has(coord):
				return false
			if tile_map[coord] != biome:
				return false
	return true


func create_structure(cx: int, cy: int, structure: Dictionary):
	for dy in structure.size.y:
		for dx in structure.size.x:
			var cell = Vector2i(
				cx + dx - Globals.WORLD_WIDTH / 2,
				cy + dy - Globals.WORLD_HEIGHT / 2
			)
			var tile = structure.tiles[dy][dx]
			if tile != null:
				structures_layer.set_cell(cell, structure.source_id, tile)


func place_structure_enemies(cx: int, cy: int, structure: Dictionary):
	var rows = structure.size.y
	var cols = structure.size.x
	var center_x = cx + cols / 2
	var center_y = cy + rows / 2
	
	var biome = tile_map[Vector2i(cx, cy)]
	if not Globals.BIOME_ENEMIES.has(biome):
		return
	
	var enemy_scene = load(Globals.BIOME_ENEMIES[biome])
	
	# Spawn enemies in a ring just outside the structure
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
		enemy.position = Vector2(
			(ex - Globals.WORLD_WIDTH / 2) * Globals.TILE_SIZE + Globals.TILE_SIZE / 2,
			(ey - Globals.WORLD_HEIGHT / 2) * Globals.TILE_SIZE + Globals.TILE_SIZE / 2
		)
		get_parent().add_child.call_deferred(enemy)


func get_neighbor_counts(x: int, y: int) -> Dictionary:
	var counts = {}
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < Globals.WORLD_WIDTH and ny >= 0 and ny < Globals.WORLD_HEIGHT:
				var tile = tile_map[Vector2i(nx, ny)]
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


func get_foreign_dirs(x: int, y: int) -> Array:
	var current_biome = tile_map[Vector2i(x, y)]
	var foreign = []
	for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var neighbor = Vector2i(x, y) + dir
		if tile_map.has(neighbor) and tile_map[neighbor] != current_biome:
			foreign.append(dir)
	return foreign


func place_decorations():
	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var biome = tile_map[Vector2i(x, y)]
			var cell = Vector2i(x - Globals.WORLD_WIDTH / 2, y - Globals.WORLD_HEIGHT / 2)

			if get_foreign_dirs(x, y).size() > 0:
				continue

			if biome == TILE_GRASS:
				if randf() < 0.05:
					decorations_layer.set_cell(cell, SOURCE_ID, DECO_FLOWER)


func place_obstacles():
	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var biome = tile_map[Vector2i(x, y)]
			var cell = Vector2i(x - Globals.WORLD_WIDTH / 2, y - Globals.WORLD_HEIGHT / 2)

			if get_foreign_dirs(x, y).size() > 0:
				continue

			var roll = randf()
			if biome == TILE_SNOW:
				if roll < 0.075:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_ICE)
			elif biome == TILE_SAND:
				if roll < 0.05:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_PALM)
			elif biome == TILE_GRASS:
				if roll < 0.05:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_ROCK)
				elif roll < 0.10:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_TREE)


func remove_small_regions():
	var visited = {}

	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var coord = Vector2i(x, y)
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


func place_enemies():

	var clusters_placed = 0
	var attempts = 0
	var max_attempts = CLUSTER_COUNT * 50

	while clusters_placed < CLUSTER_COUNT and attempts < max_attempts:
		attempts += 1

		# Pick a random tile in the world
		var cx = randi_range(0, Globals.WORLD_WIDTH - 1)
		var cy = randi_range(0, Globals.WORLD_HEIGHT - 1)
		var coord = Vector2i(cx, cy)

		# Skip if too close to center where player spawns
		var world_center = Vector2(Globals.WORLD_WIDTH / 2, Globals.WORLD_HEIGHT / 2)
		var dist = Vector2(cx, cy).distance_to(world_center)
		var max_dist = world_center.length()

		if dist < MIN_SPAWN_DIST:
			continue
		if get_foreign_dirs(cx, cy).size() > 0:
			continue

		# Get biome and check it has an enemy assigned
		var biome = tile_map[coord]
		if not Globals.BIOME_ENEMIES.has(biome):
			continue

		# Scale cluster size based on distance from center
		var t = clamp(dist / max_dist, 0.0, 1.0)
		var radius = int(lerp(2.0, 6.0, t))
		var enemy_count = int(lerp(2.0, 8.0, t))

		var scene_path = Globals.BIOME_ENEMIES[biome]
		var enemy_scene = load(scene_path)

		# Spawn enemies around the cluster center
		for i in enemy_count:
			var offset_x = randi_range(-radius, radius)
			var offset_y = randi_range(-radius, radius)
			var spawn_coord = Vector2i(cx + offset_x, cy + offset_y)

			# Validate spawn tile
			if not tile_map.has(spawn_coord):
				continue
			if tile_map[spawn_coord] != biome:
				continue
			if get_foreign_dirs(spawn_coord.x, spawn_coord.y).size() > 0:
				continue

			var enemy = enemy_scene.instantiate()
			enemy.position = Vector2(
				(spawn_coord.x - Globals.WORLD_WIDTH / 2) * Globals.TILE_SIZE * 2 + Globals.TILE_SIZE / 2,
				(spawn_coord.y - Globals.WORLD_HEIGHT / 2) * Globals.TILE_SIZE * 2 + Globals.TILE_SIZE / 2
			)
			get_parent().add_child.call_deferred(enemy)

		clusters_placed += 1


func generate_borders():
	var width = Globals.WORLD_WIDTH * Globals.TILE_SIZE
	var height = Globals.WORLD_HEIGHT * Globals.TILE_SIZE
	var thickness = Globals.TILE_SIZE * 2  # how thick the invisible wall is
	
	# Each wall: position, width, height
	var walls = [
		# Top
		[Vector2(0, -height - thickness / 2), width * 2 + thickness * 2, thickness],
		# Bottom
		[Vector2(0, height + thickness / 2), width * 2 + thickness * 2, thickness],
		# Left
		[Vector2(-width - thickness / 2, 0), thickness, height * 2],
		# Right
		[Vector2(width + thickness / 2, 0), thickness, height * 2],
	]
	
	for wall in walls:
		var body = StaticBody2D.new()
		body.position = wall[0]
		body.collision_layer = 1  # world layer
		body.collision_mask = 0
		
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(wall[1], wall[2])
		shape.shape = rect
		
		body.add_child(shape)
		get_parent().add_child.call_deferred(body)


func place_borders():
	for x in Globals.WORLD_WIDTH:
		for y in Globals.WORLD_HEIGHT:
			var cell = Vector2i(x - Globals.WORLD_WIDTH / 2, y - Globals.WORLD_HEIGHT / 2)
			var foreign = get_foreign_dirs(x, y)

			match foreign.size():
				1: place_void1(cell, foreign)
				2: place_void2(cell, foreign)
				3: place_void3(cell, foreign)


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

	# Opposite pairs — straight stripe
	if (a == Vector2i(0, -1) and b == Vector2i(0, 1)) or \
	   (a == Vector2i(0, 1)  and b == Vector2i(0, -1)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT_R90)
		return
	if (a == Vector2i(1, 0)  and b == Vector2i(-1, 0)) or \
	   (a == Vector2i(-1, 0) and b == Vector2i(1, 0)):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT_R0)
		return

	# Corner pairs
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

	# VOID3 naturally has borders on top, right, left — clear edge is bottom
	# Rotate so the clear edge matches the non-foreign direction
	if clear_dir == Vector2i(0, 1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R0)
	elif clear_dir == Vector2i(-1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R90)
	elif clear_dir == Vector2i(0, -1):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R180)
	elif clear_dir == Vector2i(1, 0):
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3_R270)
