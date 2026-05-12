extends Node


func generate_armor() -> Dictionary:
	var rarity = roll_rarity()
	var type = Globals.ARMOR_TYPES.pick_random()
	var stats = roll_stats(rarity)
	
	return {
		"type": type,
		"rarity": rarity,
		"stats": stats
	}


func roll_rarity() -> Globals.Rarity:
	var roll = randf()
	if roll < Globals.EPIC_CHANCE:
		return Globals.Rarity.EPIC
	elif roll < Globals.EPIC_CHANCE + Globals.RARE_CHANCE:
		return Globals.Rarity.RARE
	else:
		return Globals.Rarity.COMMON


func roll_stats(rarity: Globals.Rarity) -> Dictionary:
	var stat_count = Globals.RARITY_STAT_COUNT[rarity]
	var all_stats = Globals.STATS.keys()
	
	all_stats.shuffle()
	
	var result = {}
	for i in stat_count:
		var stat_name = all_stats[i]
		var range = Globals.STATS[stat_name][rarity]
		
		if range[0] is float or range[1] is float:
			result[stat_name] = randf_range(range[0], range[1])
		else:
			result[stat_name] = randi_range(range[0], range[1])
		
	return result


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
