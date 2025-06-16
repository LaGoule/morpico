extends Node2D

@onready var icon_ref: Sprite2D = $TokenIcon

var dict_token = {
	"empty" = 0,
	"circle" = 1,
	"cross" = 2,
}


func change_icon(token_type: int):
	if !token_type:
		print("Error: Changing token icon to empty!")
		return
	
	var icon_word = dict_token.find_key(token_type)
	var icon_path = "res://sprite/token_icon_" + str(icon_word) + ".png"
	var texture = load(icon_path)
	icon_ref.texture = texture
