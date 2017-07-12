extends Node

# identificadores de turno
var PLAYER_TURN = 1
var CPU_TURN = 10

# tipos de avaliação do minimax
enum minimax {MIN, MAX}

# estado do jogo
var state = [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]

# objetos
var player_mark = preload("res://nodes/objects/little-ball.scn")
var enemy_mark = preload("res://nodes/objects/little-ball-enemy.scn")
var ending_scene = preload("res://nodes/ui/ending_screen.tscn")
var plays = 0
var menu_inst
var ai_tree_iterations = 2

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

# TO DO:
# TERMINAR A AVALIAÇÃO DE JOGADAS
# FAZER A PODA ALPHA-BETA

class T_node:
	var minimax_type
	var children = []
	var value
	var is_leaf
	var coordinates
	
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
	
	func get_children():
		return children
		pass

func enemy_play():
	var play = Minimax()
	mark_instance(CPU_TURN, play.x, play.y, play.z)
	menu.halt = false
	pass

func Minimax():
	#valor de retorno
	var ret = Vector3(0, 0, 0)
	
	#constrói arvore de jogadas
	var father = T_node.new(MAX)
	var new
	for i in range (ai_tree_iterations):
		extend_tree(father)
	
	# procura a melhor jogada
	ret = search_minimax_tree(father)[1]
	
	# retorna a jogada
	return ret
	pass

func extend_tree(node):
	if node.is_leaf:
		var new
		for i in range (4):
			for j in range(4):
				for k in range(4):
					if !state[i][j][k]:
						if node.minimax_type == MIN:
							new = T_node.new(MAX)
						else:
							new = T_node.new(MIN)
						new.set_coordinates(i, j, k)
						node.append_child(new)
	else:
		var children = node.get_children()
		for i in range(children.size()):
			extend_tree(children[i])

func search_minimax_tree(node):
	if node.is_leaf:
		node.set_value(play_evaluation(node.coordinates.x, node.coordinates.z, node.coordinates.y))
		var data = [node.value, node.coordinates]
		return data
	else:
		var ret = [0, Vector3(4, 4, 4)]
		var temp = []
		if node.minimax_type == MAX:
			ret[0] = -1
			for i in range(node.get_children().size()):
				temp = search_minimax_tree(node.get_children()[i])
				if temp[0] > ret[0]:
					ret = temp
		else:
			ret[0] = 301
			for i in range(node.get_children().size()):
				temp = search_minimax_tree(node.get_children()[i])
				if temp[0] < ret[0]:
					ret = temp
		return ret

func play_evaluation(x, z, y):
	var ret = 0
	# verifica se a jogada leva à vitória: 300 pontos
	if(victory_check(CPU_TURN, x, z, y)):
		ret += 300
	else: # jogada:
		var sum
		# impede uma derrota: 50 pontos
		# deixa 3 alinhadas com 1 livre: 15 pontos
		# alinha 2 inimigas e 1 livre: 3 pontos
		# deixa 2 alinhadas com 2 livres: 3 pontos
		# alinha com 1 inimiga e 2 livres: 1 ponto
		sum =  state[0][z][y] + state[1][z][y] + state[2][z][y] + state[3][z][y]
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
