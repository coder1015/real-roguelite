extends Area2D

const SPEED: int = 300

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta: float):
	position += transform.x * SPEED * delta
	$AnimatedSprite2D.play()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() 


func _on_body_entered(body):
	queue_free()
