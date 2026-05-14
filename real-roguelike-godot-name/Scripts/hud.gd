extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_coords(text):
	$Coords.text = text
	$Coords.show()


func update_hp(hp: float) -> void:
	var simple_hp = round(10.0*hp)/10.0
	$PlayerHP.text = "HP: " + str(simple_hp)
	
func update_xp(xp: int) -> void:
	$PlayerXP.text = "XP: " + str(xp)
	
func update_level(level:int) -> void:
	$PlayerLevel.text = "Level: " + str(level)

func update_resource(resource:int) -> void:
	$PlayerResource.text = "Resource: " + str(resource)

func update_bullet_time(time_left: float) -> void:
	$BulletTimeLabel.text = "%.1f" % time_left
