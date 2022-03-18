extends Control

onready var player_list = $Players/List
onready var lobby = $".."

var clients = {}

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	$UserName/Label.connect("text_entered", self, "_on_username_changed")

func _on_username_changed(new_username):
	player_list.get_child(0).text = new_username + " (You)"
	for id in clients.keys():
		lobby.rpc_id(id, "handshake", $UserName/Label.text)

func recieved_handshake(id, data):
	print(id, ": ", data)
	var client_label = clients[id]
	client_label.text = data

func _player_connected(id: int) -> void:
	var client_label = Label.new()
	client_label.text = "Player " + str(id)
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/CutiveMono-Regular.ttf")
	client_label.set("custom_fonts/font", font)
	clients[id] = client_label
	player_list.add_child(client_label)
	lobby.rpc_id(id, "handshake", $UserName/Label.text)

func _player_disconnected(id: int) -> void:
	var client_label = clients[id]
	player_list.remove_child(client_label)
	clients[id] = null
	clients.erase(id)

func _on_Back() -> void:
	for id in clients.keys():
		player_list.remove_child(clients[id])
		get_tree().network_peer.disconnect_peer(id)
	Network.disconnect_server()
	clients = {}
	lobby.current_tab = 0

func _on_StartGame() -> void:
	get_tree().set_refuse_new_network_connections(true)
	
	var server_network_id = get_tree().get_network_unique_id()
	var settings = {}
	
	# TODO: Choose random level from levels folder
	settings["level"] = 1
	
	var player_ids : Array = clients.keys()
	player_ids.append(server_network_id)
	settings["player_ids"] = player_ids
	
	for id in clients.keys():
		print(str(id) + "\n")
		settings["player_id"] = id
		settings["player_name"] = clients[id].text
		print("Sending the start game signal!")
		lobby.rpc_id(id, "start_game", settings)
		
	settings["player_id"] = server_network_id
	settings["player_name"] = $UserName/Label.text
	if settings["player_name"] == "":
		settings["player_name"] = "Player 1"
	lobby.start_game(settings)
	
