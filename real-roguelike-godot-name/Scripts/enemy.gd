extends CharacterBody2D


var speed = 60
var player_chase = false
var player = null
var health = 100
var knockback_velocity: Vector2 = Vector2.ZERO
var damage_cooldown = false

func _ready() -> void:
	$Hurtbox.hit_taken.connect(_on_hurtbox_hit_taken)
	$Hitbox.area_entered.connect(_on_hitbox_area_entered)
	$Hitbox.monitoring = true

func _physics_process(delta):
	if player_chase:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed + knockback_velocity
	else:
		velocity = knockback_velocity

	move_and_slide()
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 10 * delta)
	check_player_overlap()

func check_player_overlap():
	if damage_cooldown:
		return

	for area in $Hitbox.get_overlapping_areas():
		if area.is_in_group("hurtbox"):
			var player = area.get_parent()
			
			var direction = (player.global_position - global_position).normalized()
			var knockback = direction * 300
			
			player.take_damage(10, knockback)
			
			damage_cooldown = true
			await get_tree().create_timer(0.5).timeout
			damage_cooldown = false
			
			break

func take_damage(damage: int, knockback: Vector2) -> void:
	health -= damage
	velocity += knockback
	if health <= 0:
		die()

func die() -> void:
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func _on_hurtbox_hit_taken(damage: int, knockback: Vector2) -> void:
	take_damage(damage, knockback)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		var player = area.get_parent()
		var direction = (player.global_position - global_position).normalized()
		var knockback = direction * 300
		player.take_damage(10, knockback)

func _animate(direction):
	$AnimatedSprite2D.play()
	if direction.x != 0 && abs(direction.x) > abs(direction.y):
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		if direction.x < 0:
			$AnimatedSprite2D.rotation = PI/2
		elif direction.x > 0:
			$AnimatedSprite2D.rotation = -PI/2
	elif direction.y != 0 && abs(direction.y) > abs(direction.x):
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = direction.y < 0
		$AnimatedSprite2D.rotation = 0
	else:
		$AnimatedSprite2D.stop()
