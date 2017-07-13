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
var ai_tree_iterations = 1

# components
onready var cube = get_node("qubic-cube")
onready var mark_placements = cube.get_node("positions")
onready var menu = get_node("menu")

func _ready():
	mark_instance(CPU_TURN, 0, 0, 0)
	pass

##############################################
# JOGADA ADVERSÁRIA
##############################################

# CLASSE DO NÓ DA ÁRVORE
class T_node:
	var minimax_type
	var children = []
	var state = [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
[[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]]]
	var value
	var is_leaf
	var coordinates = Vector3(-1, -1, -1)
	
	func _init(mmtype):
		minimax_type = mmtype
		is_leaf = true
		pass
	
	func set_value(new):
		value = new
		pass
	
	func set_state(new, x, z, y):
		for i in range(4):
			for j in range (4):
				for k in range (4):
					self.state[i][j][k] = new[i][j][k]
		if x >= 0:
			if minimax_type == MAX:
				self.state[x][z][y] = 1
			else:
				self.state[x][z][y] = 10
	
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
	father.set_state(state, -1, 0, 0)
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
					if !node.state[i][j][k]:
						if node.minimax_type == MIN:
							new = T_node.new(MAX)
						else:
							new = T_node.new(MIN)
						new.set_coordinates(i, j, k)
						new.set_state(node.state, node.coordinates.x, node.coordinates.y, node.coordinates.z)
						node.append_child(new)
	else:
		var children = node.get_children()
		for i in range(children.size()):
			extend_tree(children[i])

func search_minimax_tree(node):
	if node.is_leaf:
		node.set_value(play_evaluation(node.state, node.coordinates.x, node.coordinates.y, node.coordinates.z))
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
			ret[0] = 1000
			for i in range(node.get_children().size()):
				temp = search_minimax_tree(node.get_children()[i])
				if temp[0] < ret[0]:
					ret = temp
		return ret

func play_evaluation(state1, x, z, y):
	# impede uma derrota: 150 pontos (soma = 3)
	# vitória: 600 pontos (soma = 30)
	var ret = 0
	var defeat_risk = 3
	var victory_opportunity = 30
	var linedup4 = 600
	var interc4 = 150
	var sum
	
	# linhas em 1 dimensao
	sum = state1[0][z][y] + state1[1][z][y] + state1[2][z][y] + state1[3][z][y]
	if sum == defeat_risk:
		ret += interc4
	elif sum == victory_opportunity:
		ret += linedup4
	else:
		ret += sum
	
	sum = state1[x][0][y] + state1[x][1][y] + state1[x][2][y] + state1[x][3][y]
	if sum == defeat_risk:
		ret += interc4
	elif sum == victory_opportunity:
		ret += linedup4
	else:
		ret += sum
	
	sum = state1[x][z][0] + state1[x][z][1] + state1[x][z][2] + state1[x][z][3]
	if sum == defeat_risk:
		ret += interc4
	elif sum == victory_opportunity:
		ret += linedup4
	else:
		ret += sum
	
	# diagonais em 2 dimensoes
	if z == y:
		sum = state1[x][0][0] + state1[x][1][1] + state1[x][2][2] + state1[x][3][3]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if z + y == 3:
		sum = state1[x][0][3] + state1[x][1][2] + state1[x][2][1] + state1[x][3][0]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x == y:
		sum = state1[0][z][0] + state1[1][z][1] + state1[2][z][2] + state1[3][z][3]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x + y == 3:
		sum = state1[0][z][3] + state1[1][z][2] + state1[2][z][1] + state1[3][z][0]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x == z:
		sum = state1[0][0][y] + state1[1][1][y] + state1[2][2][y] + state1[3][3][y]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x + z == 3:
		sum = state1[0][3][y] + state1[1][2][y] + state1[2][1][y] + state1[3][0][y]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	#diagonais em 3 dimensoes
	if x == z  && z == y:
		sum = state1[0][0][0] + state1[1][1][1] + state1[2][2][2] + state1[3][3][3]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if z == y:
		sum = state1[3][0][0] + state1[2][1][1] + state1[1][2][2] + state1[0][3][3]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x == y:
		sum = state1[0][3][0] + state1[1][2][1] + state1[2][1][2] + state1[3][0][3]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
	if x == z:
		sum = state1[0][0][3] + state1[1][1][2] + state1[2][2][1] + state1[3][3][0]
		if sum == defeat_risk:
			ret += interc4
		elif sum == victory_opportunity:
			ret += linedup4
		else:
			ret += sum
	
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
	else:
		if type == PLAYER_TURN:
			menu.enemy_playing = true
	plays += 1
	
	#verifica empate
	if plays >= 64:
		call_draw()
	elif plays == 48:
		# melhora a IA caso o jogo se prolongue até 48 jogadas
		ai_tree_iterations = 3
	pass
