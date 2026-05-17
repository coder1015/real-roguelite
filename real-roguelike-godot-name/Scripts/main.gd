extends Node

@onready var pause_menu = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var position = $Player.get_position()
	var xpos = round(position.x)
	var ypos = round(position.y)
	$HUD.show_coords(xpos, ypos)
	$Player.level_up()


func new_game():
	$Player.start($StartPosition.position)
	
