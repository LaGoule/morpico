extends Node2D

var cell_id: int
var cell_size: int
var token_type: int
var tile_type: int
var token_ref: Node2D
var tile_ref: Node2D

signal token_placed(cell_id)


func _ready():
	token_ref = $Token
	tile_ref = $Tile
	var tile_sprite_ref = $Tile/TileImage
	cell_size = get_sprite_size(tile_sprite_ref)


func get_sprite_size(sprite_node: Sprite2D) -> int:
	if !sprite_node:
		print("Erreur get_sprite_size: Le sprite est null.")
		return 0
	var size = sprite_node.texture.get_size()
	return int(size.x)


func try_place_token(type: int = 1):
	if token_type != 0:
		print("This cell already has a token: ", str(token_type), ".")
		return
	
	change_token(type)
	print("Token applied on cell: ", str(cell_id))
	token_placed.emit()


func change_token(type: int = 1):
	token_type = type
	token_ref.visible = true
	return


func reset_cell():
	# cell_id = 0
	token_type = 0
	tile_type = 0
	token_ref.visible = false
