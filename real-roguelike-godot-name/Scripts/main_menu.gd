extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StartButton.pressed.connect(_on_start_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
