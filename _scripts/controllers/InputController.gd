extends Node2D

signal cell_clicked(cell)
signal cell_hovered(cell)
signal cell_unhovered(cell)

var current_hovered_cell = null


func _ready():
	self.connect("cell_hovered", Callable(self, "_on_cell_hovered"))
	self.connect("cell_unhovered", Callable(self, "_on_cell_unhovered"))

	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var selected_cell = raycast_check_for_cell()
			if selected_cell:
				emit_signal("cell_clicked", selected_cell)

	if event is InputEventMouseMotion:
		check_hover()


func check_hover():
	var cell_under_mouse = raycast_check_for_cell()
	
	if cell_under_mouse != current_hovered_cell:
		if current_hovered_cell:
			emit_signal("cell_unhovered", current_hovered_cell)
			
		if cell_under_mouse:
			emit_signal("cell_hovered", cell_under_mouse)
		
		current_hovered_cell = cell_under_mouse


func _on_cell_hovered(cell):
	if cell and cell.has_method("on_hover"):
		cell.on_hover()


func _on_cell_unhovered(cell):
	if cell and cell.has_method("on_unhover"):
		cell.on_unhover()
	

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
