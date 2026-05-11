extends Node

var equipped = {
	"Head": null,
	"Chest": null,
	"Legs": null
}


func equip(armor: Dictionary):
	# Equips armor in that slot, old armor disappears
	equipped[armor.type] = armor
	
	# Tell player to recalculate stats
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.recalculate_stats()


func get_stat_total(stat_name: String) -> int:
	# Adds up a given stat across all three equipped pieces
	var total = 0
	for slot in equipped:
		if equipped[slot] != null:
			total += equipped[slot].stats.get(stat_name, 0)
	return total

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
