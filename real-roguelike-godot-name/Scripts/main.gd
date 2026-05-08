extends Node

@onready var pause_menu = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var position = $Player.get_position()
	var xpos = str(round(position.x))
	var ypos = str(round(position.y))
	$HUD.show_coords(xpos + ", " + ypos)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		if get_tree().paused:
			pause_menu.hide_menu()
		else:
			pause_menu.show_menu()

func new_game():
	$Player.start($StartPosition.position)
	
