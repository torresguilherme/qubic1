extends Node

enum turns {PLAYER_TURN, CPU_TURN}
var current_turn
var state = [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], 
[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]

var player_mark = preload("res://nodes/objects/little-ball.scn")
var enemy_mark = preload("res://nodes/objects/little-ball-enemy.scn")

# components
onready var cube = get_node("qubic-cube")
onready var mark_placements = cube.get_node("positions")

func _ready():
	mark_instance(1, 0, 0, 0)
	pass

func player_play(x, z, y):
	pass

func enemy_play():
	pass

func victory_check():
	pass

func mark_instance(type, x, z, y):
	var new_mark
	if type == PLAYER_TURN:
		new_mark = player_mark.instance()
	else:
		new_mark = enemy_mark.instance()
	new_mark.set_translation(mark_placements.get_children()[x].get_children()[z].get_children()[y].get_translation())
	add_child(new_mark)
	state[x][z][y] = 1
	print(state)
	pass
