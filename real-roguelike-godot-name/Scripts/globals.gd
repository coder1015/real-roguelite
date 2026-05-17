extends Node

const WORLD_WIDTH = 200
const WORLD_HEIGHT = 200
const TILE_SIZE = 32

var armor_menu_open = false
var chosen_class: String = "Sword"

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
const DROP_CHANCE = 0.40  # 40% chance to drop anything
const COMMON_CHANCE = 0.70  # of drops, 70% common
const RARE_CHANCE = 0.25  # 25% rare
const EPIC_CHANCE = 0.05  # 5% epic

const ARMOR_TYPES = ["Head", "Chest", "Legs"]

# 9  stats with ranges per rarity [min, max]
const STATS = {
	"max_hp": { Rarity.COMMON: [5, 20],   Rarity.RARE: [18, 32],  Rarity.EPIC: [30, 50]  },
	"defense": { Rarity.COMMON: [5, 20],   Rarity.RARE: [18, 32],  Rarity.EPIC: [30, 50]  },
	"speed": { Rarity.COMMON: [10, 35],   Rarity.RARE: [30, 60],  Rarity.EPIC: [55, 80]  },
	"attack": { Rarity.COMMON: [1, 5],   Rarity.RARE: [4, 10],  Rarity.EPIC: [8, 15]  },
	"crit_rate": { Rarity.COMMON: [0.01, 0.06],   Rarity.RARE: [0.05, 0.1],  Rarity.EPIC: [0.09, 0.15]  },
	"auto_damage": { Rarity.COMMON: [0.1, 0.4],   Rarity.RARE: [0.3, 0.7],  Rarity.EPIC: [0.6, 1.0]  },
	"auto_speed": { Rarity.COMMON: [0.1, 1.2],   Rarity.RARE: [1.0, 2.0],  Rarity.EPIC: [1.9, 3.5]  },
	"proj_speed": { Rarity.COMMON: [50, 125],   Rarity.RARE: [120, 200],  Rarity.EPIC: [190, 300]  },
	"pierce": { Rarity.COMMON: [1, 2],   Rarity.RARE: [3, 4],  Rarity.EPIC: [5, 6]  },
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
