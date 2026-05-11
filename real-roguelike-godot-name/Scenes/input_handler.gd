extends Node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("open_armor_menu"):
		if Globals.armor_menu_open:
			var menu = get_tree().get_first_node_in_group("armor_menu")
			if menu:
				menu._on_close_pressed()
		else:
			var menu = load("res://Scenes/armor_menu.tscn").instantiate()
			get_tree().get_root().add_child(menu)
