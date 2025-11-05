extends Node

# Enumérations partagées (pourraient être dans un script GlobalEnums si nécessaire)
enum Player { HERO, ENNEMY }
enum TokenType {
	EMPTY,
	CROSS,
	CIRCLE,
	DIAMOND,
	LEAF,
}
enum TileType { 
	NORMAL,
}

var dict_player: Dictionary = {
	Player.ENNEMY: 1,
	Player.HERO: 2,
}
var dict_token: Dictionary = {
	TokenType.EMPTY: 0,
	TokenType.CROSS: 1,
	TokenType.CIRCLE: 2,
	TokenType.DIAMOND: 3,
	TokenType.LEAF: 4,
}
var dict_tile: Dictionary = {
	TileType.NORMAL: 0,
}

var current_player: Player = Player.ENNEMY
var grid_size: int = 3
var grid_data: Array = []

func initialize(size: int = 3) -> void:
	grid_size = size
	grid_data.clear()
	
	for y: int in range(grid_size):
		var row: Array = []
		for x: int in range(grid_size):
			row.append(0)
		grid_data.append(row)

func get_cell_value(x: int, y: int) -> int:
	if not (x >= 0 and x < grid_size and y >= 0 and y < grid_size):
		print("Invalid cell coordinates: (" + str(x) + ", " + str(y) + ")")
		return -1
	return grid_data[y][x]

func set_cell_value(x: int, y: int, value: int) -> void:
	if x >= 0 and x < grid_size and y >= 0 and y < grid_size:
		grid_data[y][x] = value

func get_current_player() -> int:
	return current_player

func set_current_player(player: int) -> void:
	if player == 0:
		current_player = Player.HERO
	elif player == 1:
		current_player = Player.ENNEMY
