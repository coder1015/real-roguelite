extends Area2D

var speed: float = 300.0
var lifetime: float = 0.0
var pierce: int = 0
var direction: Vector2 = Vector2.RIGHT
var _lifetime_elapsed: float = 0.0
var _hits: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite2D.play()

func _process(delta: float) -> void:
	position += direction * speed * delta

	if lifetime > 0:
		_lifetime_elapsed += delta
		if _lifetime_elapsed >= lifetime:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if lifetime <= 0:
		queue_free()

func _on_body_entered(_body) -> void:
	_hits += 1
	if _hits > pierce:
		queue_free()
