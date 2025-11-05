extends Node

var data: Node
var board: Node
var inventory: Node
var is_animating: bool = false

signal turn_started(player: int)
signal turn_ended(player: int)
signal match_ended(winner: int)
signal current_token_changed(token_type: int)


func _ready() -> void:
	add_to_group("MatchController")


func start_new_match() -> void:
	data = preload("res://_scripts/controllers/MatchData.gd").new()
	data.initialize(3)
	
	create_board()
	
	if inventory:
		inventory.visible = false

	# TODO mettre ça dans une fonction process_turn_start()
	var initial_token: int = get_current_token()
	emit_signal("current_token_changed", initial_token)
	
	emit_signal("turn_started", data.get_current_player())


func get_current_token() -> int:
	var player: int = data.get_current_player()
	if player == data.Player.HERO:
		if !inventory:
			print("Erreur: L'inventaire n'est pas initialisé.")
			return data.dict_token[data.dict_player[player]]
		return inventory.selected_token_id
	else:
		return data.dict_token[data.dict_player[player]]


func setup_inventory() -> void:
	inventory = preload("res://_scripts/Inventory.gd").new()
	add_child(inventory)
	inventory.position = Vector2(50, 50)
	inventory.connect("token_selected", Callable(self, "_on_player_token_selected"))


func _on_player_token_selected(token_id: int) -> void:
	if data.get_current_player() != data.Player.HERO:
		return

	print("Token sélectionné: " + str(token_id))

	emit_signal("current_token_changed", token_id)


func create_board() -> void:
	board = preload("res://scenes/Board.tscn").instantiate()

	board.connect("board_generated", Callable(self, "_on_board_generated"))
	board.connect("cell_clicked", Callable(self, "_on_cell_clicked"))
	
	board.connect("animation_started", Callable(self, "_on_animation_started"))
	board.connect("animation_finished", Callable(self, "_on_animation_finished"))

	add_child(board)
	board.initialize(data)

	update_board_view()


func _on_animation_started(coords: Vector2) -> void:
	is_animating = true


func _on_animation_finished(coords: Vector2) -> void:
	is_animating = false
	process_turn_end()


func _on_board_generated() -> void:
	var camera: Camera2D = get_tree().get_root().get_node("Main/Camera2D")
	if !camera:
		print("Erreur: Camera2D not found in the scene tree.")
		return
	camera._on_board_generated(board)


func update_board_view() -> void:
	for y: int in range(data.grid_size):
		for x: int in range(data.grid_size):
			var cell_value: int = data.get_cell_value(x, y)
			board.update_cell(x, y, cell_value)


func _on_cell_clicked(coords: Vector2) -> void:
	if is_animating:
		return

	var x: int = int(coords.x)
	var y: int = int(coords.y)
	
	if data.get_cell_value(x, y) != 0:
		return
	
	var token: int = get_current_token()
	
	if data.get_current_player() == data.Player.HERO && inventory:
		if !inventory.consume_token(token):
			print("Token non disponible!")
			return
	
	data.set_cell_value(x, y, token)
	board.update_cell_visual(x, y, token)
	print(data.grid_data)


func process_turn_end() -> void:
	emit_signal("turn_ended", data.get_current_player())
	
	if data.current_player == data.Player.HERO:
		data.set_current_player(data.Player.ENNEMY)
		# Cacher l'inventaire quand ce n'est pas le tour du héros
		if inventory:
			inventory.visible = false
	else:
		data.set_current_player(data.Player.HERO)
		# Montrer l'inventaire quand c'est le tour du héros
		if inventory:
			inventory.visible = true

	var token: int = get_current_token()

	emit_signal("current_token_changed", token)
	emit_signal("turn_started", data.get_current_player())


func check_winner() -> int:
	return 0

func _reset_cell_previews() -> void:
	if !board:
		return

	emit_signal("current_token_changed", get_current_token())

	var current_player: int = data.get_current_player()

	if current_player == data.Player.HERO:
		# Envoyer un faux signal de fin de tour
		emit_signal("turn_ended", current_player)
		# Puis immédiatement un signal de début de tour pour le même joueur
		emit_signal("turn_started", current_player)
		# Réémettre le token pour s'assurer que toutes les cellules sont mises à jour
		emit_signal("current_token_changed", get_current_token())
		
		print("FORÇAGE DE MISE À JOUR - Token actuel: " + str(get_current_token()))
