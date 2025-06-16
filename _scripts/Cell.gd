extends Node2D

var cell_id: int
var cell_size: int
var token_type: int
var tile_type: int
var token_ref: Node2D
var tile_ref: Node2D

var is_hovered: bool = false
var original_modulate: Color

@export var opacity_empty: float = 0.5
@export var opacity_hover: float = 0.8
@export var opacity_full: float = 1
@export var token_y_offset: int = -8 # Must be a multiple of 8 to align with pixel grid

signal token_placed(cell_id: int)

func _ready() -> void:
	reset_cell()
	original_modulate = tile_ref.modulate


func on_hover() -> void:
	if is_hovered:
		return
	is_hovered = true
	if !token_type:
		var tween: Tween = create_tween()
		tween.tween_property(tile_ref, "modulate", Color(1, 1, 1, opacity_hover), 0)

	if !token_type:
		show_preview_token(true)


func on_unhover() -> void:
	if !is_hovered:
		return
	is_hovered = false
	if !token_type:
		var tween: Tween = create_tween()
		tween.tween_property(tile_ref, "modulate", original_modulate, .1)

	if !token_type:
		show_preview_token(false)


func show_preview_token(switch: bool) -> void:
	if !switch:
		token_ref.change_icon(0)
		token_ref.visible = false
		return
	elif !token_type:
		token_ref.change_icon(get_parent().get_parent().get_current_token_id()) # TODO: Refactor with signal, no dependency on parent
		token_ref.modulate = Color(1, 1, 1, opacity_hover / 2)
		token_ref.visible = true
		return


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


func change_token(type: int = 1) -> void:
	token_type = type
	token_ref.change_icon(token_type)
	return
	
	
func anim_token_played() -> void:
	token_ref.visible = true
	token_ref.position.y = token_ref.position.y + token_y_offset - 400
	var tween_token_fall: Tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween_token_fall.tween_property(token_ref, "position", Vector2(0,0 + token_y_offset), 1.0)
	var tween_token_opacity: Tween = create_tween().set_ease(Tween.EASE_IN)
	tween_token_opacity.tween_property(token_ref, "modulate", Color(1,1,1,1), 0.3)

	var base_position: Vector2 = tile_ref.position
	var tremor_position: Vector2 = base_position + Vector2(0, 24)
	var tween_tile_tremor: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween_tile_tremor.tween_interval(0.3)
	tween_tile_tremor.tween_property(tile_ref, "position", tremor_position, 0.4)
	tween_tile_tremor.tween_property(tile_ref, "position", base_position, 0.1)

	tile_ref.modulate = Color(1, 1, 1, opacity_full)


func reset_cell() -> void:
	token_ref = $Token
	tile_ref = $Tile
	
	token_type = 0
	tile_type = 0
	cell_size = get_sprite_size($Tile/TileImage)
	
	# Reset animation
	token_ref.visible = false
	token_ref.position.y = 0 + token_y_offset
	token_ref.modulate = Color(1,1,1,0)
	tile_ref.modulate = Color(1, 1, 1, opacity_empty)
