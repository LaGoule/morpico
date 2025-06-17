extends Node

var match_controller: Node

enum GameState {
	MENU,
	MATCH,
	SHOP,
	GAMEOVER
}

var current_state: GameState = GameState.MENU

func _ready() -> void:
	# Initialize the game state
	set_game_state(GameState.MATCH)

func set_game_state(new_state: GameState) -> void:
	current_state = new_state
	match current_state:
		GameState.MENU:
			print("Game State: MENU")
		GameState.MATCH:

			if !match_controller:
				match_controller = preload("res://_scripts/controllers/MatchController.gd").new()
				add_child(match_controller)

				# Vérifier si l'inventaire existe déjà dans la scène
				var inventory_node: Node = get_node_or_null("Inventory") 
				if !inventory_node:
					# Créer l'inventaire s'il n'existe pas déjà
					inventory_node = preload("res://_scripts/Inventory.gd").new()
					inventory_node.name = "Inventory"
					add_child(inventory_node)
				
				# Assigner l'inventaire au match_controller
				match_controller.inventory = inventory_node
		
				var input_controller: Node = get_node_or_null("/root/Main/InputController") # Ajuste le chemin selon ta hiérarchie
				if !input_controller:
					push_error("InputController not found")
					return
				input_controller.connect("cell_clicked", Callable(match_controller, "_on_cell_clicked"))

			match_controller.start_new_match() # Ici on passera les paramètres nécessaires si besoin
			print("Game State: MATCH")

		GameState.SHOP:
			print("Game State: SHOP")
		GameState.GAMEOVER:
			print("Game State: GAMEOVER")
			
func get_game_state() -> GameState:
	return current_state
