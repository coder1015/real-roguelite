class_name RazorCuts
extends BaseAbility

@export var projectile_count: int = 3
@export var spread_angle: float = 20.0  # degrees between each slash

func _ready() -> void:
	super._ready()
	cooldown_time = 3.0

func _do_ability() -> void:
	var weapon = player.current_weapon
	var base_dir = (player.get_global_mouse_position() - player.global_position).normalized()
	var total_spread = spread_angle * (projectile_count - 1)
	var start_angle = -total_spread / 2.0

	for i in range(projectile_count):
		var angle = deg_to_rad(start_angle + spread_angle * i)
		var dir = base_dir.rotated(angle)
		weapon._spawn_projectile(
			player.global_position,
			dir,
			400.0,
			0.4,
			0,
			Vector2(0.8, 0.8)
		)

func _on_upgrade() -> void:
	match level:
		2: projectile_count += 1
		3: spread_angle -= 5.0  # tighter spread, more focused
