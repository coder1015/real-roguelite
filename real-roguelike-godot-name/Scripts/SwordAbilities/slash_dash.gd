class_name SlashDash
extends BaseAbility

@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.2

var _dashing: bool = false
var _dash_dir: Vector2 = Vector2.ZERO
var _dash_timer: float = 0.0

func _ready() -> void:
	super._ready()
	cooldown_time = 3.0
	
func _process(delta: float) -> void:
	super._process(delta)
	if _dashing:
		_do_slash()
		player.knockback_velocity = _dash_dir * dash_speed
		_dash_timer -= delta
		if _dash_timer <= 0:
			_dashing = false
			player.knockback_velocity = Vector2.ZERO

func _do_ability() -> void:
	_dash_dir = (player.get_global_mouse_position() - player.global_position).normalized()
	_dashing = true
	_dash_timer = dash_duration

func _do_slash() -> void:
	var weapon = player.current_weapon
	weapon._spawn_projectile(
		player.global_position,
		_dash_dir,
		300,
		0.4,
		1000,
		Vector2(1.5, 1.5)
	)

func _on_upgrade() -> void:
	match level:
		2: dash_speed += 100.0
		3: dash_duration += 0.1
