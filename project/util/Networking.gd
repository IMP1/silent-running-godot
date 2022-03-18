extends Node

const DEFAULT_PORT = 50075
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""

func _ready() -> void:
	if OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
		
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_disconnected_from_server")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server(ip_address) -> void:
	self.ip_address = ip_address
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func disconnect_server() -> void:
	for peer in get_tree().get_network_connected_peers():
		get_tree().disconnect_network_peer(peer)
	get_tree().network_peer.close_connection()
	get_tree().network_peer = null

func _connected_to_server() -> void:
	print("Connected to Server")

func _disconnected_from_server() -> void:
	print("Disconnected from Server")
