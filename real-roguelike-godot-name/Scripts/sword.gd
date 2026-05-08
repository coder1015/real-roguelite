class_name Sword
extends BaseWeapon

@onready var tip: Marker2D = $Marker2D

func _process(delta: float) -> void:
	super._process(delta)
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)

func _do_attack(target_pos: Vector2) -> void:
	var dir = (target_pos - global_position).normalized()

	_spawn_projectile(tip.global_position, dir, 80.0, 1.25, 1000, Vector2(0.5, 0.75))
