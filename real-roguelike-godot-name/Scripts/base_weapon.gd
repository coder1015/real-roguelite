class_name BaseWeapon
extends Node2D

@export var weapon_label: String = "Weapon"
@export var damage: int = 20
@export var attack_speed: float = 1.0
@export var knockback_force: float = 200.0
@export var projectile_scene: PackedScene

var _cooldown: float = 0.0
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta

func try_attack(target_pos: Vector2) -> void:
	if _cooldown > 0:
		return
	_cooldown = 1.0 / (attack_speed + player.auto_speed)
	_do_attack(target_pos)

func _do_attack(target_pos: Vector2) -> void:
	push_error(weapon_label + ": _do_attack() not implemented")

func _spawn_projectile(spawn_pos: Vector2, dir: Vector2, speed: float = 300.0, lifetime: float = 0.0, pierce: int = 0, proj_scale: Vector2 = Vector2.ONE) -> void:
	var p = projectile_scene.instantiate()
	if speed == 0:
		p.speed = speed
	else:
		p.speed = speed + player.proj_speed
	p.lifetime = lifetime
	p.pierce = pierce + player.pierce
	p.direction = dir.normalized()
	p.scale = proj_scale
	p.rotation = dir.angle()
	get_tree().root.add_child(p)
	p.global_position = spawn_pos
	var hitbox = p.get_node("Hitbox")
	
	if randf() < player.crit_rate:
		# Crit success
		hitbox.damage = ((damage + player.attack) * player.auto_damage) *  3
	else:
		# Crit fail
		hitbox.damage = (damage + player.attack) * player.auto_damage
		
	print("Damage dealt: " + str(hitbox.damage))
	hitbox.knockback_direction = dir.normalized() * knockback_force
