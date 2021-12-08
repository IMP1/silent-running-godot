extends Control

func _ready():
	$Multiplayer.visible = true
	$HostServer.visible = false
	$JoinServer.visible = false
	$HTTPRequest.request("https://api.ipify.org")

func _on_http_response(result, code, headers, body):
	print(body.get_string_from_utf8())
	$Multiplayer.external_ip_address = body.get_string_from_utf8()

remote func start_game(game_settings: Dictionary) -> void:
	print("Starting game...")
	var game = load("scenes/Game.tscn").instance()
	$"/root/Main/CurrentScene".add_child(game)
	game.setup(game_settings)
	visible = false
	queue_free()
