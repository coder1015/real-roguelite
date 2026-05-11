extends Node

const WORLD_WIDTH = 100
const WORLD_HEIGHT = 100
const TILE_SIZE = 32

const BIOME_ENEMIES = {
	Vector2i(0, 0): "res://Scenes/enemy.tscn",   # grass
	Vector2i(0, 4): "res://Scenes/enemy.tscn",   # sand  — replace with sand enemy later
	Vector2i(3, 4): "res://Scenes/enemy.tscn",   # snow  — replace with snow enemy later
}


# ----------Rarities----------
enum Rarity {COMMON, RARE, EPIC}

const RARITY_COLORS = {
	Rarity.COMMON: Color.WHITE,
	Rarity.RARE: Color.BLUE,
	Rarity.EPIC: Color.PURPLE
}

const RARITY_NAMES = {
	Rarity.COMMON: "Common",
	Rarity.RARE: "Rare",
	Rarity.EPIC: "Epic"
}

const RARITY_STAT_COUNT = {
	Rarity.COMMON: 2,
	Rarity.RARE: 3,
	Rarity.EPIC: 4
}

# Drop chances
const DROP_CHANCE = 0.25  # 25% chance to drop anything
const COMMON_CHANCE = 0.70  # of drops, 70% common
const RARE_CHANCE = 0.25  # 25% rare
const EPIC_CHANCE = 0.05  # 5% epic

const ARMOR_TYPES = ["Head", "Chest", "Legs"]

# 9 placeholder stats with ranges per rarity [min, max]
const STATS = {
	"max_hp": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"defense": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"speed": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"attack": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"crit_rate": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"auto_damage": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"auto_speed": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"proj_speed": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
	"pierce": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 20]  },
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
