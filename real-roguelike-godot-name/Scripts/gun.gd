class_name Gun
extends BaseWeapon

@onready var muzzle: Marker2D = $Marker2D

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)

func _do_attack(target_pos: Vector2) -> void:
	var dir = (target_pos - muzzle.global_position)
	_spawn_projectile(muzzle.global_position, dir)
