extends Node2D

var cell_id: int
var cell_coords: Vector2
var cell_size: int
var token_type: int
var tile_type: int
var token_ref: Node2D
var tile_ref: Node2D

var is_hovered: bool = false
var is_animating: bool = false
var current_preview_token: int = 1
var original_modulate: Color

@export var opacity_empty: float = 0.5
@export var opacity_hover: float = 0.8
@export var opacity_full: float = 1
@export var token_y_offset: int = -8 # Must be a multiple of 8 to align with pixel grid

signal token_placed(cell_coords: Vector2, token_type: int)
signal animation_started(cell_coords: Vector2)
signal animation_finished(cell_coords: Vector2)


func _ready() -> void:
	reset_cell()
	original_modulate = tile_ref.modulate

	var match_controller: Node = get_tree().get_first_node_in_group("MatchController")
	if match_controller:
		match_controller.connect("current_token_changed", Callable(self, "_on_current_token_changed"))
	else:
		print("Warning: MatchController not found in group 'MatchController'.")
		push_warning("Cell: MatchController not found for token preview")


func _on_current_token_changed(new_token: int) -> void:
	var old_token: int = current_preview_token
	current_preview_token = new_token

	if old_token != new_token && is_hovered && !token_type && !is_animating:
		token_ref.visible = false
		token_ref.modulate = Color(1, 1, 1, 0)
		token_ref.change_icon(new_token)
		token_ref.visible = true
		token_ref.modulate = Color(1, 1, 1, opacity_empty)


func on_hover() -> void:
	if is_hovered || is_animating || token_type:
		return

	is_hovered = true
	tile_ref.modulate = Color(1, 1, 1, opacity_hover)
	show_preview_token()


func on_unhover() -> void:
	if !is_hovered || is_animating || token_type:
		return

	is_hovered = false
	tile_ref.modulate = Color(1, 1, 1, opacity_empty)
	token_ref.visible = false


func show_preview_token() -> void:
	if token_type || is_animating || !is_hovered:
		return

	# Récupérer la valeur actuelle du token auprès du MatchController
	# pour assurer que la prévisualisation est toujours à jour
	var match_controller = get_tree().get_first_node_in_group("MatchController")
	if match_controller:
		current_preview_token = match_controller.get_current_token()

	token_ref.change_icon(current_preview_token) 
	token_ref.visible = true
	token_ref.modulate = Color(1, 1, 1, opacity_empty)
	

func get_sprite_size(sprite_node: Sprite2D) -> int:
	if !sprite_node:
		print("Erreur get_sprite_size: Le sprite est null.")
		return 0
	var size: Vector2 = sprite_node.texture.get_size()
	return int(size.x)


func place_token(type: int = 1) -> void:
	if token_type:
		print("This cell already has a token: ", str(token_type), ".")
		return
	elif type == 0:
		print("Error: Trying to place empty token!")
		return
	
	is_animating = true
	change_token(type)
	emit_signal("animation_started", cell_coords)
	anim_token_placement()
	emit_signal("token_placed", cell_coords)


func change_token(type: int = 1) -> void:
	token_type = type
	token_ref.change_icon(token_type)
	return


func anim_token_placement() -> void:
	# Initialisation
	token_ref.visible = true
	token_ref.position.y = token_ref.position.y + token_y_offset - 400
	token_ref.modulate = Color(1, 1, 1, 0)

	# Animation
	var base_position: Vector2 = tile_ref.position
	var tremor_position: Vector2 = base_position + Vector2(0, 24)
	var token_tween: Tween = create_tween()
	var tile_tween: Tween = create_tween()

	# Animation de chute
	token_tween.tween_property(token_ref, "position", Vector2(0, 0 + token_y_offset), 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# Animation d'opacité en parallèle
	token_tween.parallel().tween_property(token_ref, "modulate", Color(1, 1, 1, 1), 0.3)

	# Tremblement de tuile en parallèle mais avec délai
	tile_tween.tween_interval(0.3)
	tile_tween.tween_property(tile_ref, "position", tremor_position, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT_IN)
	tile_tween.tween_property(tile_ref, "position", base_position, 0.1)

	# Finalisation
	tile_ref.modulate = Color(1, 1, 1, opacity_full)

	# Signal de fin
	token_tween.finished.connect(func() -> void: 
		is_animating = false
		emit_signal("animation_finished", cell_coords)
	)


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
