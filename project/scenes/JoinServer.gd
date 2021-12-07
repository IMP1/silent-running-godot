extends Control

onready var ip_address_field = $IP/IpAddress

func _ready() -> void:
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_to_server() -> void:
	$CurrentState.text = "Connected!"

func _connection_failed() -> void:
	$CurrentState.text = "Failed to connect."

func _server_disconnected() -> void:
	$CurrentState.text = "Server disconnected."

func _on_Connect() -> void:
	# TODO: Add additional text validation
	if ip_address_field.text != "":
		Network.join_server(ip_address_field.text)
		$CurrentState.text = "Connecting..."

func _on_Back() -> void:
	# TODO: Cancel any connection attempt
	$"../Multiplayer".visible = true
	visible = false

remote func start_game(game_settings: Dictionary) -> void:
	print("Starting game...")
	var game = load("scenes/Game.tscn").instance()
	$"/root/Main/CurrentScene".add_child(game)
	game.setup(game_settings)
	visible = false
	queue_free()
