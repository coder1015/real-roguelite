class_name Sword
extends BaseWeapon

func _process(delta: float) -> void:
	super._process(delta)
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)

func _do_attack(target_pos: Vector2) -> void:
	var dir = (target_pos - global_position).normalized()

	_spawn_projectile(global_position, dir, 80.0, 0.25, 1, Vector2(2.0, 2.5))
