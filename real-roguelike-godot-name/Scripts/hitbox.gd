class_name HitBox
extends Area2D

@export var damage = 20
@export var knockback_direction = 100

func _ready() -> void:
	add_to_group("hitbox")
	monitoring = false
	monitorable = true
