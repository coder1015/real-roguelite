extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		if get_tree().paused:
			hide_menu()
		else:
			show_menu()


func show_menu():
	show()
	get_tree().paused = true


func hide_menu():
	hide()
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false
