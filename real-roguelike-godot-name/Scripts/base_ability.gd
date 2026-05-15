class_name BaseAbility
extends Node2D

@export var ability_name: String = "Ability"
@export var resource_cost: int = 10
@export var cooldown_time: float = 1.0
var _cooldown: float = 0.0
var unlocked: bool = false
var level: int = 0
var player: CharacterBody2D
#push
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta

func activate() -> void:
	if not unlocked:
		return
	if _cooldown > 0:
		return
	if player.resource < resource_cost:
		return
	player.resource -= resource_cost
	_cooldown = cooldown_time
	player.get_parent().get_node("HUD").update_resource(player.resource)
	_do_ability()

func upgrade() -> void:
	level += 1
	if level == 1:
		unlocked = true
	_on_upgrade()

func _do_ability() -> void:
	push_error(ability_name + ": _do_ability() not implemented")

func _on_upgrade() -> void:
	pass
