extends Camera

var rotation_speed = 2
var up
var down
var left
var right
var theta
var phi

onready var cube = get_node("../").get_translation()
onready var radius = get_translation().distance_to(Vector3(4, 4, 4))
onready var initial = get_translation()

func _ready():
	theta = 0
	phi = 0
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		right = -1
	else:
		right = 0
	if Input.is_action_pressed("ui_left"):
		left = 1
	else:
		left = 0
	if Input.is_action_pressed("ui_up"):
		up = -1
	else:
		up = 0
	if Input.is_action_pressed("ui_down"):
		down = 1
	else:
		down = 0
	
	theta += (left + right) * delta * rotation_speed
	phi += (up + down) * delta * rotation_speed
	# movimento
	set_translation(Vector3(radius * sin(phi) * cos(theta), radius * cos(phi), radius * sin(phi) * sin(theta)))
	look_at(Vector3(4, 4, 4), Vector3(0, 1, 0))
