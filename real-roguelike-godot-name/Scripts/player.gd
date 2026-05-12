extends CharacterBody2D

# speed is in pixels per second
var screen_size
var hp: float
var invincible: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var current_weapon: BaseWeapon = null
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100
var resource: int = 100
var max_resource: int = 100

# Base Stats
const BASE_MAX_HP: float = 100.0
const BASE_DEFENSE = 0
const BASE_SPEED = 200
const BASE_ATTACK = 0
const BASE_CRIT_RATE: float = 0.0
const BASE_AUTO_DAMAGE: float = 1.0
const BASE_AUTO_SPEED: float = 0.0
const BASE_PROJ_SPEED: float = 0.0
const BASE_PIERCE: int = 0

# Current Stat Variables
var max_hp: float = BASE_MAX_HP             # Flat max hp, default = 100.0
var defense = BASE_DEFENSE                  # Gets converted into a multiplicative and additive damage reduction, default = 0
var speed = BASE_SPEED                      # Flat speed, default = 200
var attack = BASE_ATTACK                    # Additive to weapon base damage, default = 0
var crit_rate: float = BASE_CRIT_RATE       # Chance to crit from 0.0 to 1.0, success is a time 3 multiplier to final damage, default = 0.0
var auto_damage: float = BASE_AUTO_DAMAGE   # Ranges from 1.0 to 2.0, multiplicative damage increase, default = 1.0
var auto_speed: float = BASE_AUTO_SPEED     # Additive to the cooldown calculation, default = 0.0
var proj_speed: float = BASE_PROJ_SPEED     # Additive to base speed in the _spawn_projectile method, default = 0.0
var pierce: int = BASE_PIERCE               # Additive to base pierce in the _spawn_projectile method, default = 0
# Implement below stats later
var ability_damage
var cooldown
var time_cost_reduction
# Think about knockback and knockback reduction
# Also maybe stat that increases iframes after being hit?
# Lifesteal? Probably not cause would be hard to balance and not really add much to the game

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("player")
	hp = max_hp
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	screen_size = get_viewport_rect().size
	$Hurtbox.hit_taken.connect(_on_hurtbox_hit_taken)
	get_parent().get_node("HUD").update_hp(hp)
	get_parent().get_node("HUD").update_xp(xp)
	get_parent().get_node("HUD").update_level(level)
	get_parent().get_node("HUD").update_resource(resource)
	hide()
	$weapon_system/Ranged/Gun.hide()
	$weapon_system/Ranged/EBow.hide()
	$weapon_system/Melee/Sword.hide()
	set_weapon($weapon_system/Melee/Sword)
	
	$ability_system/SwordAbilities/BigSlash.upgrade()
	$ability_system/SwordAbilities/SlashDash.upgrade()
	$ability_system/SwordAbilities/RazorCuts.upgrade()

	var width = Globals.WORLD_WIDTH * Globals.TILE_SIZE
	var height = Globals.WORLD_HEIGHT * Globals.TILE_SIZE
	
	$Camera2D.limit_left   = -width
	$Camera2D.limit_top    = -height
	$Camera2D.limit_right  =  width
	$Camera2D.limit_bottom =  height
	

func _physics_process(delta: float) -> void:
	var input_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		input_velocity.y -= 1	
	
	if Input.is_action_just_pressed("ability_1"):
		$ability_system/SwordAbilities/BigSlash.activate()
	if Input.is_action_just_pressed("ability_2"):
		$ability_system/SwordAbilities/SlashDash.activate()
	if Input.is_action_just_pressed("ability_3"):
		$ability_system/SwordAbilities/RazorCuts.activate()
	
	if input_velocity.length() > 0:
		input_velocity = input_velocity.normalized() * speed

	velocity = input_velocity + knockback_velocity
	
	if Input.is_action_pressed("shoot_projectile"):
		if current_weapon:
			current_weapon.try_attack(get_global_mouse_position())

	_animate()
	move_and_slide()
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10 * delta)


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_hurtbox_hit_taken(damage: int, knockback: Vector2) -> void:
	take_damage(damage, knockback)


func take_damage(damage: int, knockback: Vector2) -> void:
	if invincible:
		return
	#print("take_damage called with: ", damage)
	var damage_taken = max(1.0, damage * (1.0 / (1.0 + (1.0/300.0)*defense)) - (1.0/100.0)*defense)
	hp -= damage_taken
	#print("damage taken: ", damage_taken)
	#print("hp: ", hp)
	knockback_velocity = knockback
	invincible = true
	$IFrameTimer.start(0.6)
	if hp <= 0:
		die()
	get_parent().get_node("HUD").update_hp(hp)


func set_weapon(weapon: BaseWeapon) -> void:
	if current_weapon:
		current_weapon.hide()
	current_weapon = weapon
	current_weapon.show()


func die():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func gain_xp(amount: int) -> void:
	xp += amount
	get_parent().get_node("HUD").update_xp(xp)


func level_up():
	if xp >= xp_to_next_level and level <= 7:
		level += 1
		xp = xp - xp_to_next_level
		xp_to_next_level = 100 * level
		get_parent().get_node("HUD").update_level(level)
		get_parent().get_node("HUD").update_xp(xp)
		
	


func recalculate_stats(old_max_hp):
	max_hp = BASE_MAX_HP + ArmorManager.get_stat_total("max_hp")
	defense = BASE_DEFENSE + ArmorManager.get_stat_total("defense")
	speed = BASE_SPEED + ArmorManager.get_stat_total("speed")
	attack = BASE_ATTACK + ArmorManager.get_stat_total("attack")
	crit_rate = BASE_CRIT_RATE + ArmorManager.get_stat_total("crit_rate")
	auto_damage = BASE_AUTO_DAMAGE + ArmorManager.get_stat_total("auto_damage")
	auto_speed = BASE_AUTO_SPEED + ArmorManager.get_stat_total("auto_speed")
	proj_speed = BASE_PROJ_SPEED + ArmorManager.get_stat_total("proj_speed")
	pierce = BASE_PIERCE + ArmorManager.get_stat_total("pierce")
	
	hp = min(hp + (max_hp - old_max_hp), max_hp)
	#print("Auto damage: " + str(auto_damage))
	get_parent().get_node("HUD").update_hp(hp)


func _animate():
	if velocity.length() > 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		return
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		if velocity.x < 0:
			$AnimatedSprite2D.rotation = PI/2
		elif velocity.x > 0:
			$AnimatedSprite2D.rotation = -PI/2
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = velocity.y < 0
		$AnimatedSprite2D.rotation = 0


func _on_i_frame_timer_timeout() -> void:
	invincible = false
