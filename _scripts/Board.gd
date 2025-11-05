extends Node2D

const GRID_SIZE: int = 3
const GRID_GAP: int = 4
const CELL_SIZE: int = 128
const CELL_MID: float = float(CELL_SIZE) / 2

var grid_view: Array = []
var match_data: Node

signal board_generated()
signal cell_clicked(coords: Vector2)
signal animation_started(coords: Vector2)
signal animation_finished(coords: Vector2)


func initialize(data: Node) -> void:
	if !data:
		push_error("Board: match_data est vide.")
		return
	
	match_data = data
	grid_view.clear()
	
	var cell_scene: PackedScene = preload("res://scenes/Cell.tscn")
	var counter: int = 1
	
	for y: int in range(match_data.grid_size):
		grid_view.append([])
		for x: int in range(match_data.grid_size):
			var cell: Node2D = cell_scene.instantiate()
			cell.position = Vector2(
				x * (CELL_MID + GRID_GAP) + CELL_MID / 2, 
				y * (CELL_MID + GRID_GAP) + CELL_MID / 2)
			cell.cell_id = counter
			cell.cell_coords = Vector2(x, y)

			# Configurer la cellule avec l'état initial du jeu
			var initial_value: int = match_data.get_cell_value(x, y)
			if initial_value != 0:
				cell.token_type = 0

			grid_view[y].append(cell)
			add_child(cell)
			
			cell.connect("token_placed", Callable(self, "_on_token_placed"))
			cell.connect("animation_started", Callable(self, "_on_cell_animation_started"))
			cell.connect("animation_finished", Callable(self, "_on_cell_animation_finished"))
			
			counter += 1
			
	center_board()
	board_generated.emit()


func center_board() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	var board_size: Vector2 = get_size()
	position = screen_size / 2 - board_size / 2


func get_size() -> Vector2:
	var width: float = GRID_SIZE * (CELL_MID) + (GRID_SIZE - 1) * GRID_GAP
	var height: float = GRID_SIZE * (CELL_MID) + (GRID_SIZE - 1) * GRID_GAP
	return Vector2(width, height)


func _on_token_placed(cell_coords: Vector2) -> void:
	emit_signal("cell_clicked", cell_coords)


func update_cell_visual(x: int, y: int, token_type: int) -> void:
	if x >= 0 && x < grid_view.size() && y >= 0 && y < grid_view[x].size():
		var cell: Node2D = grid_view[y][x]
		if cell.token_type != token_type:
			cell.place_token(token_type)


func update_cell(x: int, y: int, value: int) -> void:
	update_cell_visual(x, y, value)


func _on_reset_button_down() -> void:
	for row: Array in grid_view:
		for cell: Node2D in row:
			cell.reset_cell()


func _on_cell_animation_started(coords: Vector2) -> void:
	emit_signal("animation_started", coords)

func _on_cell_animation_finished(coords: Vector2) -> void:
	emit_signal("animation_finished", coords)
