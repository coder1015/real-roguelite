extends Node

# Layers
@onready var ground_layer = $"../Ground"
@onready var decorations_layer = $"../Decorations"
@onready var obstacles_layer = $"../Obstacles"

# World settings
const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100
const TILE_SIZE = 32

const MIN_BIOME_SIZE = 50  # any clump smaller than this gets removed

# Noise — temperature and moisture are now fully independent axes
var temp_noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()

# Tile Atlas Coordinates
const TILE_GRASS = Vector2i(0, 0)
const TILE_SAND  = Vector2i(0, 2)
const TILE_SNOW  = Vector2i(3, 2)

# Decoration Tiles
const DECO_FLOWER = Vector2i(3, 1)
const DECO_VOID1  = Vector2i(1, 0)
const DECO_VOID2  = Vector2i(2, 0)
const DECO_VOID2_ALT = Vector2i(3, 0)
const DECO_VOID3  = Vector2i(0, 1)

# Obstacle Tiles
const OBST_TREE = Vector2i(1, 1)
const OBST_ROCK = Vector2i(2, 1)
const OBST_PALM = Vector2i(2, 2)
const OBST_ICE  = Vector2i(1, 3)

# Rotation alternative tile IDs
const ROT_0   = 0      # no rotation
const ROT_90  = 16384  # 90° clockwise
const ROT_180 = 32768  # 180°
const ROT_270 = 49152  # 270° clockwise

const SOURCE_ID = 3

var tile_map = {}


func _ready() -> void:
	setup_noise()
	generate_ground()
	place_decorations()
	place_obstacles()
	place_borders()


func setup_noise():
	temp_noise.seed = randi()
	temp_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	temp_noise.frequency = 0.02

	# Completely different seed so temperature and moisture are unrelated
	moisture_noise.seed = temp_noise.seed + 9999
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	moisture_noise.frequency = 0.02


func get_ground_tile(t: float, m: float) -> Vector2i:
	# t = temperature (-1 cold, +1 hot)
	# m = moisture    (-1 dry,  +1 wet)
	#
	#            dry (m < 0)     wet (m >= 0)
	# cold:        snow              snow
	# temperate:   sand              grass
	# hot:         sand              grass

	if t < 0.0:
		return TILE_SNOW          # cold = snow regardless of moisture
	elif m < 0.0:
		return TILE_SAND          # warm + dry = sand
	else:
		return TILE_GRASS         # warm + wet = grass


func generate_ground():
	# Pass 1: noise → tile_map
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var t = temp_noise.get_noise_2d(x, y)
			var m = moisture_noise.get_noise_2d(x, y)
			tile_map[Vector2i(x, y)] = get_ground_tile(t, m)

	# Pass 2: smooth 4x to remove speckles
	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	smooth_biomes()
	remove_small_regions()
	

	# Pass 3: apply to tilemap
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			ground_layer.set_cell(
				Vector2i(x - WORLD_WIDTH / 2, y - WORLD_HEIGHT / 2),
				SOURCE_ID,
				tile_map[Vector2i(x, y)]
			)


func smooth_biomes():
	var new_map = tile_map.duplicate()
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var coord = Vector2i(x, y)
			var neighbors = get_neighbor_counts(x, y)
			var dominant = get_dominant_tile(neighbors)
			if neighbors.get(dominant, 0) >= 4:
				new_map[coord] = dominant
	tile_map = new_map


func get_neighbor_counts(x: int, y: int) -> Dictionary:
	var counts = {}
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < WORLD_WIDTH and ny >= 0 and ny < WORLD_HEIGHT:
				var tile = tile_map[Vector2i(nx, ny)]
				counts[tile] = counts.get(tile, 0) + 1
	return counts


func get_foreign_dirs(x: int, y: int) -> Array:
	var current_biome = tile_map[Vector2i(x, y)]
	var foreign = []
	
	for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var neighbor = Vector2i(x, y) + dir
		if tile_map.has(neighbor) and tile_map[neighbor] != current_biome:
			foreign.append(dir)
			
	return foreign


func get_dominant_tile(counts: Dictionary) -> Vector2i:
	var best_tile = TILE_GRASS
	var best_count = 0
	for tile in counts:
		if counts[tile] > best_count:
			best_count = counts[tile]
			best_tile = tile
	return best_tile


func place_decorations():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var biome = tile_map[Vector2i(x, y)]
			var cell = Vector2i(x - WORLD_WIDTH / 2, y - WORLD_HEIGHT / 2)

			if biome == TILE_GRASS:
				if randf() < 0.05:
					decorations_layer.set_cell(cell, SOURCE_ID, DECO_FLOWER)


func place_obstacles():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var biome = tile_map[Vector2i(x, y)]
			var cell = Vector2i(x - WORLD_WIDTH / 2, y - WORLD_HEIGHT / 2)
			var roll = randf()

			if biome == TILE_SNOW:
				if roll < 0.1:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_ICE)
			elif biome == TILE_SAND:
				if roll < 0.05:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_PALM)
			elif biome == TILE_GRASS:
				if roll < 0.1:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_ROCK)
				elif roll < 0.2:
					obstacles_layer.set_cell(cell, SOURCE_ID, OBST_TREE)


func remove_small_regions():
	var visited = {}
	
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var coord = Vector2i(x, y)
			if visited.has(coord):
				continue
			
			# Flood fill to find the full region
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
			
			# If region is too small, replace with dominant neighbor biome
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


func place_borders():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var cell = Vector2i(x - WORLD_WIDTH / 2, y - WORLD_HEIGHT / 2)
			var foreign = get_foreign_dirs(x, y)
			
			match foreign.size():
				1:
					place_void1(cell, foreign)
				2:
					place_void2(cell, foreign)
				3:
					place_void3(cell, foreign)


func place_void1(cell: Vector2i, foreign: Array):
	# VOID1 border is naturally on top, rotate to face the one foreign neighbor
	var dir = foreign[0]
	var rotation = dir_to_rotation_void1(dir)
	decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID1, rotation)

func dir_to_rotation_void1(dir: Vector2i) -> int:
	if dir == Vector2i(0, -1): return ROT_0    # foreign is up,    border already on top
	if dir == Vector2i(1, 0):  return ROT_90   # foreign is right, rotate border to right
	if dir == Vector2i(0, 1):  return ROT_180  # foreign is down,  rotate border to bottom
	if dir == Vector2i(-1, 0): return ROT_270  # foreign is left,  rotate border to left
	return ROT_0


func place_void2(cell: Vector2i, foreign: Array):
	var a = foreign[0]
	var b = foreign[1]
	
	# Check for opposite pairs — use VOID2_ALT (straight stripe)
	if (a == Vector2i(0, -1) and b == Vector2i(0, 1)) or \
	   (a == Vector2i(0, 1) and b == Vector2i(0, -1)):
		# up + down — vertical stripe, no rotation needed
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT, ROT_90)
		return
	if (a == Vector2i(1, 0) and b == Vector2i(-1, 0)) or \
	   (a == Vector2i(-1, 0) and b == Vector2i(1, 0)):
		# left + right — horizontal stripe, rotate 90
		decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2_ALT, ROT_0)
		return
	
	# Otherwise it's a corner — use VOID2 rotated to match
	# VOID2 naturally has borders on top and right
	var rotation = corner_to_rotation(a, b)
	decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID2, rotation)


func corner_to_rotation(a: Vector2i, b: Vector2i) -> int:
	var pair = [a, b]
	# Top + right = natural orientation
	if pair.has(Vector2i(0, -1)) and pair.has(Vector2i(1, 0)):  return ROT_0
	# Right + down
	if pair.has(Vector2i(1, 0))  and pair.has(Vector2i(0, 1)):  return ROT_90
	# Down + left
	if pair.has(Vector2i(0, 1))  and pair.has(Vector2i(-1, 0)): return ROT_180
	# Left + top
	if pair.has(Vector2i(-1, 0)) and pair.has(Vector2i(0, -1)): return ROT_270
	return ROT_0


func place_void3(cell: Vector2i, foreign: Array):
	# VOID3 naturally has borders on top, right, left — so bottom is the clear edge
	# Find the one direction that is NOT foreign and rotate so that faces down
	var all_dirs = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	var clear_dir = Vector2i(0, 0)
	for dir in all_dirs:
		if not foreign.has(dir):
			clear_dir = dir
			break
	
	var rotation = dir_to_rotation_void3(clear_dir)
	decorations_layer.set_cell(cell, SOURCE_ID, DECO_VOID3, rotation)


func dir_to_rotation_void3(clear_dir: Vector2i) -> int:
	# Rotate so the clear edge faces the non-foreign neighbor
	if clear_dir == Vector2i(0, 1):  return ROT_0    # clear is down,  already correct
	if clear_dir == Vector2i(-1, 0): return ROT_90   # clear is left,  rotate so left faces down
	if clear_dir == Vector2i(0, -1): return ROT_180  # clear is up,    rotate so up faces down
	if clear_dir == Vector2i(1, 0):  return ROT_270  # clear is right, rotate so right faces down
	return ROT_0
