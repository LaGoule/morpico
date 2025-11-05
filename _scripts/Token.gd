extends Node2D

@onready var icon_ref: Sprite2D = $TokenIcon

var dict_token: Dictionary = {
	"empty" = 0,
	"cross" = 1,
	"circle" = 2,
	"diamond" = 3,
	"leaf" = 4,
}

var textures: Dictionary = {}
var current_token_type: int = -1


func _ready() -> void:
	for token_name: String in dict_token.keys():
		if token_name != "empty":
			var path: String = "res://sprite/token_icon_" + token_name + ".png"
			textures[dict_token[token_name]] = load(path)


func change_icon(token_type: int) -> void:
	if token_type == current_token_type:
		return
		
	current_token_type = token_type
	
	if token_type == 0:
		icon_ref.visible = false
		return
	else:
		icon_ref.visible = true
	
	if textures.has(token_type):
		icon_ref.texture = textures[token_type]
	else:
		push_warning("Token type not found in preloaded textures: " + str(token_type))
