extends TextureFrame

#onready
onready var options = get_node("options")
onready var buttons = options.get_children()
onready var manager = get_node("../")
onready var game_state = manager.state
onready var warning = get_node("warning")
onready var ok_button = get_node("ok")

#controle
var all_selected = false
var position_filled = false
var ok_to_go = false
var enemy_playing = false
var halt = false

func _ready():
	for i in range(buttons.size()):
		for j in range(4):
			buttons[i].add_item(str(j))
	ok_button.set_toggle_mode(true)
	set_process(true)
	pass

func _process(delta):
	if !all_selected && !halt:
		ok_to_go = false
		position_filled = false
		if buttons[0].selected > -1 && buttons[1].selected > -1 && buttons[2].selected > -1:
			all_selected = true
	
	if all_selected && !halt:
		if game_state[buttons[0].selected][buttons[2].selected][buttons[1].selected] != 0:
			position_filled = true
			ok_to_go = false
		else:
			position_filled = false
			ok_to_go = true
	
	if position_filled && !halt:
		warning.set_text("Esta posição já está ocupada!")
	elif !position_filled && !halt:
		warning.set_text("")
	
	if ok_to_go && !halt:
		ok_button.set_disabled(false)
	elif !ok_to_go && !halt:
		ok_button.set_disabled(true)
	
	if ok_button.is_pressed():
		manager.mark_instance(manager.PLAYER_TURN, buttons[0].selected, buttons[2].selected, buttons[1].selected)
		ok_button.set_pressed(false)
		ok_to_go = false
	
	if enemy_playing:
		warning.set_text("Adversário jogando... aguarde!")
		ok_to_go = false
		enemy_playing = false
		halt = true
		manager.enemy_play()