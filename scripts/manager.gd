extends Node

enum turns {ZERO, PLAYER_TURN, CPU_TURN}
var current_turn
var state = [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]

var player_mark = preload("res://nodes/objects/little-ball.scn")
var enemy_mark = preload("res://nodes/objects/little-ball-enemy.scn")
var ending_scene = preload("res://nodes/ui/ending_screen.tscn")
var plays = 0
var menu_inst

# components
onready var cube = get_node("qubic-cube")
onready var mark_placements = cube.get_node("positions")
onready var menu = get_node("menu")

func _ready():
	mark_instance(CPU_TURN, 3, 3, 1)
	pass

func enemy_play():
	play = Minimax()
	mark_instance(CPU_TURN, play.x, play.y, play.z)
	menu.halt = false
	pass

func Minimax():
	#valor de retorno
	var ret = Vector3(0, 0, 0)
	
	#arvore de jogadas
	
	
	#retorna a jogada
	return ret
	pass

func victory_check(type, x, z, y):
	var end = 0
	#checa linhas retas
	if state[0][z][y] == type && state[1][z][y] == type && state[2][z][y] == type && state[3][z][y] == type:
		end = type
	elif state[x][0][y] == type && state[x][1][y] == type && state[x][2][y] == type && state[x][3][y] == type:
		end = type
	elif state[x][z][0] == type && state[x][z][1] == type && state[x][z][2] == type && state[x][z][3] == type:
		end = type
	
	#checa diagonais em duas dimensoes
	elif state[0][0][y] == type && state[1][1][y] == type && state[2][2][y] == type && state[3][3][y] == type:
		end = type
	elif state[x][0][0] == type && state[x][1][1] == type && state[x][2][2] == type && state[x][3][3] == type:
		end = type
	elif state[0][z][0] == type && state[1][z][1] == type && state[2][z][2] == type && state[3][z][3] == type:
		end = type
	elif state[0][z][3] == type && state[1][z][2] == type && state[2][z][1] == type && state[3][z][0] == type:
		end = type
	elif state[0][3][y] == type && state[1][2][y] == type && state[2][1][y] == type && state[3][0][y] == type:
		end = type
	elif state[x][0][3] == type && state[x][1][2] == type && state[x][2][1] == type && state[x][3][0] == type:
		end = type
	
	#checa diagonais em 3 dimensoes
	elif state[0][0][0] == type && state[1][1][1] == type && state[2][2][2] == type && state[3][3][3] == type:
		end = type
	elif state[0][0][3] == type && state[1][1][2] == type && state[2][2][1] == type && state[3][3][0] == type:
		end = type
	elif state[0][3][3] == type && state[1][2][2] == type && state[2][1][1] == type && state[3][0][0] == type:
		end = type
	elif state[0][3][0] == type && state[1][2][1] == type && state[2][1][2] == type && state[3][0][3] == type:
		end = type
	
	if end:
		var es = ending_scene.instance()
		if end == PLAYER_TURN:
			es.get_node("Label").set_text("Vitória!")
		else:
			es.get_node("Label").set_text("Derrota!")
		add_child(es)
		get_tree().set_pause(true)
	pass

func call_draw():
	var es = ending_scene.instance()
	es.get_node("Label").set_text("Empate!")
	add_child(es)
	get_tree().set_pause(true)
	pass

func mark_instance(type, x, z, y):
	var new_mark
	if type == PLAYER_TURN:
		new_mark = player_mark.instance()
	else:
		new_mark = enemy_mark.instance()
	new_mark.set_translation(mark_placements.get_children()[x].get_translation() +
	mark_placements.get_children()[x].get_children()[z].get_translation() +
	mark_placements.get_children()[x].get_children()[z].get_children()[y].get_translation())
	add_child(new_mark)
	state[x][z][y] = type
	
	#verifica condicao de vitória
	victory_check(type, x, z, y)
	plays += 1
	
	#verifica empate
	if plays >= 64:
		call_draw()
	pass
