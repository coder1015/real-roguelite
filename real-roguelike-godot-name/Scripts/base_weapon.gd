class_name BaseWeapon
extends Node2D

@export var weapon_label: String = "Weapon"
@export var damage: int = 20
@export var attack_speed: float = 1.0
@export var knockback_force: float = 200.0

var _cooldown: float = 0.0

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta

func try_attack(target_pos: Vector2) -> void:
	if _cooldown > 0:
		return
	_cooldown = 1.0 / attack_speed
	_do_attack(target_pos)

func _do_attack(target_pos: Vector2) -> void:
	push_error(weapon_label + ": _do_attack() not implemented")
