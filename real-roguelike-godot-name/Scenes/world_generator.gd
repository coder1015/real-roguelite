extends Node

# Layers
@onready var ground_layer = $"../Ground"
@onready var decorations_layer = $"../Decorations"
@onready var obstacles_layer = $"../Obstacles"

# World settings
const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100
const TILE_SIZE = 32

# Noise
var elevation_noise = FastNoiseLite.new()
var moisture_noise = FastNoiseLite.new()

# Tile Atlas Corrdinates
const TILE_GRASS = Vector2i(0, 0)
const TILE_SAND = Vector2i(3, 1)
const TILE_SNOW = Vector2i(2, 2)

# Decoration Tiles
const DECO_FLOWER = Vector2i(2, 1)
const DECO_VOID1 = Vector2i(1, 0)
const DECO_VOID2 = Vector2i(2, 0)
const DECO_VOID3 = Vector2i(3, 0)

# Obstacle Tiles
const OBST_TREE = Vector2i(0, 1)
const OBST_ROCK = Vector2i(1, 1)
const OBST_PALM = Vector2i(1, 2)
const OBST_ICE = Vector2i(0, 3)

const SOURCE_ID = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_noise()
	generate_ground()
	place_decorations()
	place_obstacles()


func setup_noise():
	elevation_noise.seed = randi()
	elevation_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	elevation_noise.frequency = 0.05

	# Moisture uses a different seed so it's independent from elevation
	moisture_noise.seed = elevation_noise.seed + 1
	moisture_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	moisture_noise.frequency = 0.05
	

func generate_ground():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var e = elevation_noise.get_noise_2d(x, y)
			var m = moisture_noise.get_noise_2d(x, y)
			var tile = get_ground_tile(e, m)
			ground_layer.set_cell(Vector2i(x - WORLD_WIDTH/2, y - WORLD_HEIGHT/2), SOURCE_ID, tile)
			
			
func get_ground_tile(e: float, m: float) -> Vector2i:
	# e = elevation (-1 to 1), m = moisture (-1 to 1)
	if e < -0.33:
		return TILE_SNOW
	elif e >= -0.33 and e < 0.33:
		return TILE_SAND
	elif e >= 0.33 and e <= 1:
		return TILE_GRASS
	else:
		return TILE_GRASS
		
func place_decorations():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var e = elevation_noise.get_noise_2d(x, y)
			if e >= 0.33:
				var roll = randf()
				if roll < 0.05:
					decorations_layer.set_cell(Vector2i(x, y), SOURCE_ID, DECO_FLOWER)


func place_obstacles():
	for x in WORLD_WIDTH:
		for y in WORLD_HEIGHT:
			var e = elevation_noise.get_noise_2d(x, y)
			var m = moisture_noise.get_noise_2d(x, y)

			if e < -0.33:
				var roll = randf()
				# Snow biome gets ice
				if roll < 0.1:
					obstacles_layer.set_cell(Vector2i(x, y), SOURCE_ID, OBST_ICE)
			elif e < 0.33:
				var roll = randf()
				# Sand biome gets palm trees
				if roll < 0.15:
					obstacles_layer.set_cell(Vector2i(x, y), SOURCE_ID, OBST_PALM)
			else:
				var roll = randf()
				# Grass biome gets rocks and trees
				if roll < 0.1:
					obstacles_layer.set_cell(Vector2i(x, y), SOURCE_ID, OBST_ROCK)
				elif roll < 0.2:
					obstacles_layer.set_cell(Vector2i(x, y), SOURCE_ID, OBST_TREE)
	
	
	
