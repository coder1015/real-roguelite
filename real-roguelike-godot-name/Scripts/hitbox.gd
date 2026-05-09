class_name HitBox
extends Area2D

@export var damage: float = 20.0
@export var knockback_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("hitbox")
	monitoring = false
	monitorable = true
