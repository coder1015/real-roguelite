extends Area2D

var armor_data = {}

#func setup(armor: Dictionary):
	#armor_data = armor
	#
	#var rarity_name = Globals.RARITY_NAMES[armor.rarity]
	#$Label.text = rarity_name + " " + armor.type
	#
	#$Label.add_theme_color_override("font_color", Globals.RARITY_COLORS[armor.rarity])


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			open_equip_popup()


func open_equip_popup():
	var popup_scene = load("res://Scenes/equip_popup.tscn")
	var popup = popup_scene.instantiate()
	popup.new_armor = armor_data
	popup.drop_ref = self
	get_tree().get_root().add_child(popup)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rarity_name = Globals.RARITY_NAMES[armor_data.rarity]
	$Label.text = rarity_name + " " + armor_data.type
	$Label.add_theme_color_override("font_color", Globals.RARITY_COLORS[armor_data.rarity])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
