extends Node

const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100
const TILE_SIZE = 32

const BIOME_ENEMIES = {
	Vector2i(0, 0): "res://Scenes/enemy.tscn",   # grass
	Vector2i(0, 4): "res://Scenes/enemy.tscn",   # sand  — replace with sand enemy later
	Vector2i(3, 4): "res://Scenes/enemy.tscn",   # snow  — replace with snow enemy later
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
