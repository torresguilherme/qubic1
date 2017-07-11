extends TextureFrame

onready var label = get_node("Label")
onready var ok_button = get_node("ok")
var scene = preload("res://nodes/scenes/main-scene.tscn")

func _ready():
	ok_button.set_toggle_mode(true)
	set_process(true)
	pass

func _process(delta):
	if ok_button.is_pressed():
		get_tree().set_pause(false)
		get_tree().change_scene_to(scene)