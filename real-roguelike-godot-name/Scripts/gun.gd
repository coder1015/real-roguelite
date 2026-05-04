extends Node2D

const PROJECTILE = preload("res://Scenes/projectile.tscn")

@onready var muzzle: Marker2D = $Marker2D

func _process(delta: float):
	look_at(get_global_mouse_position())
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	#if rotation_degrees > 90 and rotation_degrees < 270:
		#scale.y = -1
	#else:
		#scale.y = 1
	
	if Input.is_action_just_pressed("shoot_projectile"):
		var projectile_instance = PROJECTILE.instantiate()
		get_tree().root.add_child(projectile_instance)
		projectile_instance.global_position = muzzle.global_position
		projectile_instance.rotation = rotation
