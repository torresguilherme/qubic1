extends Node

enum turns {ZERO, PLAYER_TURN, CPU_TURN}
enum minimax {MIN, MAX}
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

##############################################
# JOGADA ADVERSÁRIA
##############################################

class T_node:
	var minimax_type
	var children = []
	var value
	var is_leaf
	var coordinates = Vector3(0, 0, 0)
	
	func _init(mmtype):
		minimax_type = mmtype
		is_leaf = true
		pass
	
	func set_value(new):
		value = new
		pass
	
	func set_coordinates(x, z, y):
		coordinates = Vector3(x, z, y)
		pass
	
	func append_child(new):
		children.append(new)
		is_leaf = false
		pass
	

func enemy_play():
	var play = Minimax()
	mark_instance(CPU_TURN, play.x, play.y, play.z)
	menu.halt = false
	pass

func Minimax():
	#valor de retorno
	var ret = Vector3(0, 0, 0)
	
	#arvore de jogadas
	var father = T_node.new(MAX)
	var new
	for i in range (4):
		for j in range(4):
			for k in range(4):
				if !state[i][j][k]:
					new = T_node.new(MIN)
					new.set_coordinates(i, j, k)
					father.append_child(new)
	
	#retorna a jogada
	return ret
	pass

func play_evaluation(x, z, y):
	var ret = 0
	# verifica se a jogada leva à vitória: 300 pontos
	if(victory_check(CPU_TURN, x, z, y)):
		ret += 300
	else:
		# verifica se a jogada impediria uma derrota: 40 pontos
		pass
	return ret

##############################################
# FIM DA JOGADA ADVERSÁRIA
##############################################

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
	
	return end
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
	var end = victory_check(type, x, z, y)
	if end:
		var es = ending_scene.instance()
		if end == PLAYER_TURN:
			es.get_node("Label").set_text("Vitória!")
		else:
			es.get_node("Label").set_text("Derrota!")
		add_child(es)
		get_tree().set_pause(true)
	plays += 1
	
	#verifica empate
	if plays >= 64:
		call_draw()
	pass
