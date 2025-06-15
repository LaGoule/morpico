extends Camera2D

@onready var board = $"../Board"

func center_on_board():
	var board_size = board.get_size()
	var board_center = board.position + board_size / 2
	global_position = board_center


func _on_board_generated() -> void:
	center_on_board()
	pass
