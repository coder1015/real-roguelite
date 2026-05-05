class_name HurtBox
extends Area2D

signal hit_taken(damage: int, knockback: Vector2)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox"):
		emit_signal("hit_taken", area.damage, area.knockback_direction)
