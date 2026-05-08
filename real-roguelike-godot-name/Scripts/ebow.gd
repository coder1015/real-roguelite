class_name EBow
extends BaseWeapon

@onready var muzzle: Marker2D = $Marker2D

func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _process(delta: float) -> void:
	super._process(delta)
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if _cooldown <= 0:
		$AnimatedSprite2D.play("idle")

func _do_attack(target_pos: Vector2) -> void:
	$AnimatedSprite2D.play("reload")
	var dir = (target_pos - muzzle.global_position)
	_spawn_projectile(muzzle.global_position, dir)
