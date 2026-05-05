extends CharacterBody2D


var speed = 60
var player_chase = false
var player = null
var health = 100


func _physics_process(delta: float) -> void:
	if player_chase: 
		var direction = player.position - position
		position += direction/speed
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
	


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
