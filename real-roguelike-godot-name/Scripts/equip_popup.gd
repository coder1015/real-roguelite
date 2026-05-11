extends Control

var new_armor = {}
var drop_ref = null    # reference to the armor_drop node so we can remove it

var player

#func setup(armor: Dictionary, drop: Area2D):
	#new_armor = armor
	#drop_ref = drop
	#
	#get_tree().paused = true  # pause the game while popup is open
	#
	#display_new_armor()
	#display_current_armor()


func display_new_armor():
	var rarity_name = Globals.RARITY_NAMES[new_armor.rarity]
	$PanelContainer/VBoxContainer/Title.text = "New " + new_armor.type + " Found!"
	
	var title = $PanelContainer/VBoxContainer/HBoxContainer/NewArmorPanel/NewArmorTitle
	title.text = rarity_name + " " + new_armor.type
	title.add_theme_color_override("font_color", Globals.RARITY_COLORS[new_armor.rarity])
	
	# Populate new armor stats
	var stats_container = $PanelContainer/VBoxContainer/HBoxContainer/NewArmorPanel/NewArmorStats
	for stat in new_armor.stats:
		var label = Label.new()
		label.text = stat + ": " + str(new_armor.stats[stat])
		stats_container.add_child(label)


func display_current_armor():
	var current = ArmorManager.equipped[new_armor.type]
	
	var title = $PanelContainer/VBoxContainer/HBoxContainer/CurrentArmorPanel/CurrentArmorTitle
	var stats_container = $PanelContainer/VBoxContainer/HBoxContainer/CurrentArmorPanel/CurrentArmorStats
	
	if current == null:
		title.text = "No " + new_armor.type + " equipped"
		return
	
	var rarity_name = Globals.RARITY_NAMES[current.rarity]
	title.text = rarity_name + " " + current.type
	title.add_theme_color_override("font_color", Globals.RARITY_COLORS[current.rarity])
	
	for stat in current.stats:
		var label = Label.new()
		label.text = stat + ": " + str(current.stats[stat])
		stats_container.add_child(label)


func _on_equip_pressed():
	ArmorManager.equip(new_armor)
	if drop_ref:
		drop_ref.queue_free()    # remove the drop from the world
	close()


func _on_close_pressed():
	close()


func close():
	get_tree().paused = false
	queue_free()


func center_panel():
	var screen_size = get_viewport_rect().size
	var panel_size = $PanelContainer.size
	$PanelContainer.position = player.position - (screen_size - panel_size) / 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	get_tree().paused = true
	$PanelContainer/VBoxContainer/HBoxContainer2/EquipButton.pressed.connect(_on_equip_pressed)
	$PanelContainer/VBoxContainer/HBoxContainer2/CloseButton.pressed.connect(_on_close_pressed)
	center_panel.call_deferred()
	display_new_armor()
	display_current_armor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
