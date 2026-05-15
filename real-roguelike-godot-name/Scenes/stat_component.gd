extends Node2D
 
@export var attributes: Globals
@export var health_bar: StatBar

func _ready() -> void:
	pass  # player will call update_health_bar

func update_health_bar(current, max_health):
	if health_bar:
		health_bar.update_bar(current, max_health)

func _physics_process(delta):
	pass
