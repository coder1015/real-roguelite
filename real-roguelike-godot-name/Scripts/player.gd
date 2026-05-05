extends CharacterBody2D

# speed is in pixels per second
var speed: int = 200
var screen_size
var hp: int = 100

func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	_animate()
	

	move_and_slide()
	
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func take_damage():
	hp =- 10
func die():
	queue_free()

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
