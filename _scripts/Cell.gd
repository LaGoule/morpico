extends Node2D

var cell_id: int
var cell_size: int
var token_type: int
var tile_type: int
var token_ref: Node2D
var tile_ref: Node2D
# Must be a multiple of 8 to align with pixel grid
@export var token_y_offset: int = -8

signal token_placed(cell_id)

func _ready():
	reset_cell()


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
	elif type == 0:
		print("Error: Trying to place empty token!")
		return
	
	change_token(type)
	anim_token_played()
	token_placed.emit()


func change_token(type: int = 1):
	token_type = type
	token_ref.change_icon(token_type)
	return
	
	
func anim_token_played():
	token_ref.visible = true
	var tween_token_fall: Tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween_token_fall.tween_property(token_ref, "position", Vector2(0,0 + token_y_offset), 1.0)
	var tween_token_opacity: Tween = create_tween().set_ease(Tween.EASE_IN)
	tween_token_opacity.tween_property(token_ref, "modulate", Color(1,1,1,1), 0.3)
	
	var base_position = tile_ref.position
	var tremor_position = base_position + Vector2(0, 24)
	var tween_tile_tremor: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_tile_tremor.tween_interval(0.3)
	tween_tile_tremor.tween_property(tile_ref, "position", tremor_position, 0.4)
	tween_tile_tremor.tween_property(tile_ref, "position", base_position, 0.1)
	


func reset_cell():
	token_ref = $Token
	tile_ref = $Tile
	
	cell_size = get_sprite_size($Tile/TileImage)
	
	# Prepare for placing animation
	token_ref.position.y += -200 + token_y_offset
	token_ref.modulate = Color(1,1,1,0)
	
	token_type = 0
	tile_type = 0
	token_ref.visible = false
