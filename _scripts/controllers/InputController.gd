extends Node2D

signal cell_clicked(cell: Node)
signal cell_hovered(cell: Node)
signal cell_unhovered(cell: Node)

var current_hovered_cell: Node


func _ready() -> void:
	self.connect("cell_hovered", Callable(self, "_on_cell_hovered"))
	self.connect("cell_unhovered", Callable(self, "_on_cell_unhovered"))


func _input(event: InputEvent) -> void:
	if is_animation_in_progress():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var selected_cell: Node = raycast_check_for_cell()
			if selected_cell:
				emit_signal("cell_clicked", selected_cell.cell_coords)
	elif event is InputEventMouseMotion:
		check_hover()


func check_hover() -> void:
	var cell_under_mouse: Node = raycast_check_for_cell()
	
	if current_hovered_cell == cell_under_mouse:
		return
	else:
		if current_hovered_cell:
			emit_signal("cell_unhovered", current_hovered_cell)
		if cell_under_mouse:
			emit_signal("cell_hovered", cell_under_mouse)
		
		current_hovered_cell = cell_under_mouse


func is_animation_in_progress() -> bool:
	var match_controller: Node = get_tree().get_first_node_in_group("MatchController")
	if match_controller:
		return match_controller.is_animating
	return false


func _on_cell_hovered(cell: Node) -> void:
	if cell and cell.has_method("on_hover"):
		cell.on_hover()


func _on_cell_unhovered(cell: Node) -> void:
	if cell and cell.has_method("on_unhover"):
		cell.on_unhover()
	

func raycast_check_for_cell() -> Node:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result: Array = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
