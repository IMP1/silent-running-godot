extends Control


func _ready():
	$Multiplayer.visible = true
	$HostServer.visible = false
	$JoinServer.visible = false

remote func start_game(game_settings: Dictionary) -> void:
	print("Starting game...")
	var game = load("scenes/Game.tscn").instance()
	$"/root/Main/CurrentScene".add_child(game)
	game.setup(game_settings)
	visible = false
	queue_free()
