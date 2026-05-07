class_name Gun
extends BaseWeapon

const PROJECTILE = preload("res://Scenes/projectile.tscn")
@onready var muzzle: Marker2D = $Marker2D

func _process(delta: float) -> void:
	super._process(delta)
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)

func _do_attack(target_pos: Vector2) -> void:
	var projectile_instance = PROJECTILE.instantiate()
	get_tree().root.add_child(projectile_instance)
	projectile_instance.global_position = muzzle.global_position
	projectile_instance.rotation = rotation
	projectile_instance.get_node("Hitbox").damage = damage
