extends Node2D

@onready var icon_ref: Sprite2D = $TokenIcon

var dict_token: Dictionary = {
	"empty" = 0,
	"circle" = 1,
	"cross" = 2,
}


func change_icon(token_type: int) -> void:
	if icon_ref.texture == load("res://sprite/token_icon_" + str(dict_token.find_key(token_type)) + ".png"):
		return

	var icon_word: String = dict_token.find_key(token_type)
	var icon_path: String = "res://sprite/token_icon_" + str(icon_word) + ".png"
	var texture: Texture2D = load(icon_path) # TODO considering preloading sprite in an array
	icon_ref.texture = texture
