class_name EBow
extends BaseWeapon

const PROJECTILE = preload("res://Scenes/projectile.tscn")
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
	var projectile = PROJECTILE.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = muzzle.global_position
	projectile.rotation = rotation
	var hitbox = projectile.get_node("Hitbox")
	hitbox.damage = damage
	hitbox.knockback_direction = (target_pos - muzzle.global_position).normalized() * knockback_force
