extends Node2D

const GRID_SIZE: int = 3
const GRID_GAP: int = 5
const CELL_SIZE: int = 128
const CELL_MID: int = CELL_SIZE / 2

var grid_data: Array = []

signal board_generated
signal turn_played


func _ready():
	generate_board_data(GRID_SIZE)
	generate_board_view(grid_data)


func generate_board_data(size: int = 3):
	var _counter = 1;
	
	for y in size:
		grid_data.append([])
		for x in size:
			grid_data[y].append(0)
			#print("Cell ", str(_counter), ": ", str(x), ", ", str(y), " generated.")
			_counter += 1
	#print("Board data's completed.")
	

func generate_board_view(data: Array):
	if !data:
		print("Erreur: grid_data est vide.")
		return
		
	var cell_scene = preload("res://scenes/Cell.tscn")
	var _counter = 1
	
	for y in data.size():
		for x in data[y].size():
			var cell = cell_scene.instantiate()
			cell.position = Vector2(
				x * (CELL_MID + GRID_GAP) + CELL_MID / 2, 
				y * (CELL_MID + GRID_GAP) + CELL_MID / 2)
			cell.cell_id = _counter
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


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var selected_cell = raycast_check_for_cell()
			if selected_cell:
				#print("Clicked cell: ", selected_cell.cell_id)
				selected_cell.try_place_token(1);
	
	
func raycast_check_for_cell():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
	
#func _on_destroy():
	#cell.disconnect("token_placed")
	
