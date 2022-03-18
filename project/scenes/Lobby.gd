extends TabContainer

onready var main = $"/root/Main"

func _ready():
	current_tab = 0
	$HTTPRequest.request("https://api.ipify.org")

func _on_http_response(result, code, headers, body):
	print(body.get_string_from_utf8())
	$Multiplayer.external_ip_address = body.get_string_from_utf8()

remotesync func start_game(game_settings: Dictionary) -> void:
	print("Starting game...")
	main.transition_scene("res://scenes/Game.tscn")
	main.current_scene.setup(game_settings)

remote func handshake(data) -> void:
	var id = get_tree().get_rpc_sender_id()
	print(is_network_master())
	if is_network_master():
		$HostServer.recieved_handshake(id, data)
	else:
		print("ID (should be 1): ", id)
		$JoinServer.recieved_handshake(data)
