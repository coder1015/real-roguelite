extends Control

var player
var can_close = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("armor_menu")
	Globals.armor_menu_open = true
	player = get_tree().get_first_node_in_group("player")
	get_tree().paused = true
	$PanelContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	display_all_slots()
	center_panel.call_deferred()
	await get_tree().process_frame
	can_close = true


func center_panel():
	var screen_size = get_viewport_rect().size
	var panel_size = $PanelContainer.size
	$PanelContainer.position = player.position - screen_size/2 + Vector2(100, 0)


func display_all_slots():
	$PanelContainer/VBoxContainer/Title.text = "Equipped Armor"
	
	display_slot("Head",
	$PanelContainer/VBoxContainer/HeadSlot/HeadTitle,
	$PanelContainer/VBoxContainer/HeadSlot/HeadStats)
	display_slot("Chest",
	$PanelContainer/VBoxContainer/ChestSlot/ChestTitle,
	$PanelContainer/VBoxContainer/ChestSlot/ChestStats)
	display_slot("Legs",
	$PanelContainer/VBoxContainer/LegsSlot/LegsTitle,
	$PanelContainer/VBoxContainer/LegsSlot/LegsStats)


func display_slot(slot: String, title_label: Label, stats_container: VBoxContainer):
	var armor = ArmorManager.equipped[slot]
	
	if armor == null:
		title_label.text = "No " + slot + " equipped"
		title_label.add_theme_color_override("font_color", Color.GRAY)
		return
	
	var rarity_name = Globals.RARITY_NAMES[armor.rarity]
	title_label.text = rarity_name + " " + armor.type
	title_label.add_theme_color_override("font_color", Globals.RARITY_COLORS[armor.rarity])
	
	# Clear any old stat labels first
	for child in stats_container.get_children():
		child.queue_free()
	
	for stat in armor.stats:
		var label = Label.new()
		if armor.stats[stat] is float:
			label.text = stat + ": " + str(snappedf(armor.stats[stat], 0.01))
		else:
			label.text = stat + ": " + str(armor.stats[stat])
		stats_container.add_child(label)


func _on_close_pressed():
	if not can_close:
		return
	Globals.armor_menu_open = false
	get_tree().paused = false
	queue_free()


#func _input(event):
	#if event.is_action_pressed("open_armor_menu"):
		#print("menu received C key")
		#get_viewport().set_input_as_handled()
		#_on_close_pressed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
