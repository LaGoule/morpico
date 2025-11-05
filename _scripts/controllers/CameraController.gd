extends Camera2D

var board: Node2D = null


func center_on_board() -> void:
	var board_size: Vector2 = board.get_size()
	var board_center: Vector2 = board.position + board_size / 2
	global_position = board_center


func _on_board_generated(b: Node2D) -> void:
	board = b
	if board:
		center_on_board()
		print("Camera centered on board.")
