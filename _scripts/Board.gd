extends Node2D

const GRID_SIZE: int = 5
const GRID_GAP: int = 4
const CELL_SIZE: int = 128
const CELL_MID: int = CELL_SIZE / 2

var grid_data: Array = []
var grid_view: Array = []

signal board_generated
signal turn_played


func _ready():
	generate_board_data(GRID_SIZE)
	generate_board_view(grid_data)


func generate_board_data(size: int = 3):
	for y in size:
		grid_data.append([])
		for x in size:
			grid_data[y].append(0)


func generate_board_view(data: Array):
	if !data:
		print("Erreur: grid_data est vide.")
		return
		
	var cell_scene = preload("res://scenes/Cell.tscn")
	var _counter = 1
	
	for y in data.size():
		grid_view.append([])
		for x in data[y].size():
			var cell = cell_scene.instantiate()
			cell.position = Vector2(
				x * (CELL_MID + GRID_GAP) + CELL_MID / 2, 
				y * (CELL_MID + GRID_GAP) + CELL_MID / 2)
			cell.cell_id = _counter
			grid_view[y].append(cell)
			add_child(cell)
			cell.connect("token_placed", Callable(self, "_on_token_placed"))
			_counter += 1
			
	center_board()
	board_generated.emit()


func center_board():
	var screen_size = get_viewport_rect().size
	var board_size = get_size()
	position = screen_size / 2 - board_size / 2


func get_size() -> Vector2:
	var width = GRID_SIZE * (CELL_MID) + (GRID_SIZE - 1) * GRID_GAP
	var height = GRID_SIZE * (CELL_MID) + (GRID_SIZE - 1) * GRID_GAP
	return Vector2(width, height)


func _on_token_placed():
	turn_played.emit()


func _on_reset_button_down() -> void:
	for i in self.get_children():
		i.reset_cell()
	
