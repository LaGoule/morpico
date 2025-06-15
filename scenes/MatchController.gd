extends Node

enum Player { HERO, ENNEMY, }
enum TileType { NORMAL, }
enum TokenType {
	EMPTY,
	CROSS,
	CIRCLE,
}

@export var first_to_play: Player = Player.ENNEMY
@export var current_player: Player = first_to_play

var players_name: Dictionary = {  "vous" = 0, "l'ordinateur" = 1, }

var players_base_token: Dictionary = {
	"Hero" = TokenType.CIRCLE,
	"Ennemy" = TokenType.CROSS,
}

func _ready() -> void:
	print("C'est à " + players_name.find_key(current_player) + " de jouer.")

func _on_turn_played():
	if current_player == Player.ENNEMY:
		current_player = Player.HERO
	else:
		current_player = Player.ENNEMY
	print("C'est à " + players_name.find_key(current_player) + " de jouer.")
	
	
