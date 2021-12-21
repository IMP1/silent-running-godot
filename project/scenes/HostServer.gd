extends Control

onready var client_list = $Clients/List
onready var lobby = $".."

var clients = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func _player_connected(id: int) -> void:
	var client_label = Label.new()
	client_label.text = "Player " + str(id)
	client_label.set("custom_fonts/font", load("res://fonts/CutiveMono-Regular.ttf"))
	clients[id] = client_label
	client_list.add_child(client_label)

func _player_disconnected(id: int) -> void:
	var client_label = clients[id]
	client_list.remove_child(client_label)
	clients[id] = null

func _on_Back() -> void:
	# TODO: Cancel any connection hosting
	$"../Multiplayer".visible = true
	visible = false

func _on_StartGame() -> void:
	get_tree().set_refuse_new_network_connections(true)
	
	var server_network_id = get_tree().get_network_unique_id()
	var settings = {}
	var player_ids : Array = clients.keys()
	player_ids.append(server_network_id)
	settings["player_ids"] = player_ids
	
	for id in clients.keys():
		print(str(id) + "\n")
		settings["player_id"] = id
		lobby.rpc_id(id, "start_game", settings)
		
	settings["player_id"] = server_network_id
	lobby.start_game(settings)
	
