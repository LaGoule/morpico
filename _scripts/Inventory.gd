extends Node2D

signal token_selected(token_id: int)

var available_tokens = []
var selected_token_id = 1  # Par défaut: token rond (joueur)
var token_buttons = []

# Structure de données pour un token
# {
#   "id": int,        # Identifiant unique du token
#   "type": String,   # Type visuel (cross, circle, diamond, etc.)
#   "count": int,     # Nombre disponible (-1 pour infini)
#   "texture": Texture2D # Texture associée
# }


func _ready() -> void:
	initialize_inventory()
	create_ui()


func initialize_inventory() -> void:
	
	# Ajouter les tokens par défaut
	add_token({
		"id": 2,
		"type": "circle",
		"count": -1,  # Infini
		"texture": preload("res://sprite/token_icon_circle.png")
	})

	add_token({
		"id": 3,
		"type": "diamond",
		"count": 3,
		"texture": preload("res://sprite/token_icon_diamond.png")
	})
	
	selected_token_id = 2


func add_token(token_data: Dictionary) -> void:
	available_tokens.append(token_data)


func create_ui() -> void:
	var inventory_container: Node = HBoxContainer.new()
	inventory_container.name = "InventoryContainer"
	add_child(inventory_container)

	inventory_container.position = Vector2(10, 10)

	for token: Dictionary in available_tokens:
		var button: Node = TextureButton.new()
		button.texture_normal = token["texture"]
		button.custom_minimum_size = Vector2(50, 50)
		
		if token["count"] > 0:
			var label: Node = Label.new()
			label.name = "CountLabel"
			label.text = str(token["count"])
			label.position = Vector2(35, 35)
			button.add_child(label)
		
		button.connect("pressed", Callable(self, "_on_token_button_pressed").bind(token["id"]))
		
		inventory_container.add_child(button)
		token_buttons.append({"button": button, "token_id": token["id"]})
	
	update_selection_ui()


func _on_token_button_pressed(token_id: int) -> void:

	for token: Dictionary in available_tokens:
		if token["id"] == token_id:
			if token["count"] != 0:  # -1 ou > 0
				selected_token_id = token_id
				update_selection_ui()
				emit_signal("token_selected", token_id)
			return


func update_selection_ui() -> void:
	# Mettre à jour l'UI pour montrer quel token est sélectionné
	for item: Dictionary in token_buttons:
		var is_selected: bool = item["token_id"] == selected_token_id
		item["button"].modulate = Color(1, 1, 1, 1) if is_selected else Color(0.7, 0.7, 0.7, 1)


func update_count_ui(token_id: int) -> void:
	for token: Dictionary in available_tokens:
		if token["id"] == token_id and token["count"] >= 0:
			# Trouver le bouton correspondant
			for item: Dictionary in token_buttons:
				if item["token_id"] == token_id:
					var label: Label = item["button"].get_node_or_null("CountLabel")
					
					if label:
						label.text = str(token["count"])
						label.visible = true
						
						# Coloration selon le compteur
						if token["count"] == 0:
							label.modulate = Color(1, 0.3, 0.3, 1)  # Rouge pour zéro
						else:
							label.modulate = Color(1, 1, 1, 1)
							
					else:
						# Créer un nouveau label uniquement si nécessaire
						var new_label = Label.new()
						new_label.name = "CountLabel"
						new_label.text = str(token["count"])
						new_label.position = Vector2(35, 35)
						
						if token["count"] == 0:
							new_label.modulate = Color(1, 0.3, 0.3, 1)
							
						item["button"].add_child(new_label)
					return


func consume_token(token_id: int) -> bool:
	# Chercher le token concerné
	for token: Dictionary in available_tokens:
		if token["id"] == token_id:
			if token["count"] == -1:
				return true
			
			if token["count"] <= 0:
				print("Token " + str(token_id) + " épuisé")
				return false
			
			token["count"] -= 1
			
			update_count_ui(token_id)
			
			if token["count"] == 0:
				disable_token_button(token_id)
				if token_id == selected_token_id:
					select_next_available_token()
			
			return true

	return false

func select_next_available_token() -> void:
	for token: Dictionary in available_tokens:
		if token["count"] != 0:  # -1 ou > 0
			selected_token_id = token["id"]
			update_selection_ui()
			emit_signal("token_selected", token["id"])
			print("Auto-sélection du token: " + str(token["id"]))
			return

func disable_token_button(token_id: int) -> void:
	for item: Dictionary in token_buttons:
		if item["token_id"] == token_id:
			item["button"].modulate = Color(0.5, 0.5, 0.5, 0.5)
			
			var label: Label = item["button"].get_node_or_null("Label")
			if label:
				label.text = "0"
				label.modulate = Color(1, 0.3, 0.3, 1)
