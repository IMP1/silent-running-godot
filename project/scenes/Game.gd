extends Node2D

const player_script = preload("res://objects/Player.gd")

func setup(game_settings):
	# TODO: Procedural Level Generation
	var player_positions = []
	player_positions.append(Vector2(400, 200))
	player_positions.append(Vector2(400, 400))
	# TODO: Randomise player positions
	
	var player_ids = game_settings["player_ids"]
	for i in player_ids:
		var player_object : KinematicBody2D = load("objects/Player.tscn").instance()
		$Players.add_child(player_object)
		player_object.game_scene = self
		player_object.set_name("Player " + str(i))
		player_object.set_network_master(i)
		player_object.position = player_positions.pop_back()
		if i == game_settings["player_id"]:
			# TODO: Add camera node (and maybe add player script?)
			var camera = Camera2D.new()
			player_object.add_child(camera)
			camera.current = true

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func _server_disconnected():
	print("Lost server connection!\n")

func _player_disconnected(args):
	print("Disconnect!")
	print(args)
	print("\n")

remotesync func add_torpedo(position, direction):
	print("pew pew")
	var torpedo = load("res://objects/Torpedo.tscn").instance()
	$Torpedos.add_child(torpedo)
	torpedo.position = position
	torpedo.direction = direction
