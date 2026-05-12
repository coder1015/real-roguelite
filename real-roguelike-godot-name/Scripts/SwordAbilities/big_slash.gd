class_name BigSlash
extends BaseAbility

func _ready() -> void:
	super._ready()
	cooldown_time = 3.0
	
func _do_ability() -> void:
	var weapon = player.current_weapon
	var dir = (player.get_global_mouse_position() - player.global_position).normalized()
	weapon._spawn_projectile(
		player.global_position,
		dir,
		0,       # stationary
		0.4,     # lifetime
		1000,    # pierce everything
		Vector2(2.5, 2.5)  # big
	)

func _on_upgrade() -> void:
	match level:
		2: resource_cost -= 2
		3: resource_cost -= 2
