extends CharacterBody2D

# speed is in pixels per second
var speed: int = 200
var screen_size
var hp: int = 100
var invincible: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var current_weapon: BaseWeapon = null
var xp: int = 0
var level: int = 1
var xp_to_next_level: int = 100

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	screen_size = get_viewport_rect().size
	$Hurtbox.hit_taken.connect(_on_hurtbox_hit_taken)
	get_parent().get_node("HUD").update_hp(hp)
	get_parent().get_node("HUD").update_xp(xp)
	get_parent().get_node("HUD").update_level(level)

	hide()
	set_weapon($weapon_system/Melee/Sword)
	
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
	print("take_damage called with: ", damage)
	hp -= damage
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
	if xp >= xp_to_next_level and level < 7:
		level += 1
		xp = xp - xp_to_next_level
		xp_to_next_level = 100 * level
		get_parent().get_node("HUD").update_level(level)
		get_parent().get_node("HUD").update_xp(xp)



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
