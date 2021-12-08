extends Node2D

const player_script = preload("res://objects/Player.gd")

var alive_players : int = 0

func setup(game_settings):
	# TODO: Procedural Level Generation
	var player_positions = []
	player_positions.append(Vector2(400, 200))
	player_positions.append(Vector2(400, 400))
	# TODO: Randomise player positions
	
	var player_ids : Array = game_settings["player_ids"]
	for i in player_ids:
		var player_object : KinematicBody2D = load("objects/Player.tscn").instance()
		$Players.add_child(player_object)
		player_object.game_scene = self
		player_object.player_id = i
		player_object.set_name("Player " + str(i))
		player_object.set_network_master(i)
		player_object.position = player_positions.pop_back()
		if i == game_settings["player_id"]:
			# TODO: Add camera node (and maybe add player script?)
			var camera = Camera2D.new()
			player_object.add_child(camera)
			camera.current = true
	alive_players = player_ids.size()

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
	var torpedo = load("res://objects/Torpedo.tscn").instance()
	$Torpedos.add_child(torpedo)
	torpedo.position = position
	torpedo.direction = direction

remotesync func add_sound(position):
	var sound = load("res://objects/Sound.tscn").instance()
	$Sounds.add_child(sound)
	sound.position = position
	sound.start()

remotesync func add_ping(position, direction):
	# TODO: Add ping object. Have them be slightly visible (to show where they've come from)
#	var ping = load("res://objects/Ping.tscn").instance()
#	$Pings.add_child(ping)
#	ping.position = position
#	ping.direction = direction
	pass

remotesync func player_died(player_id):
	alive_players -= 1
	if alive_players == 1:
		# TODO: Declare winner
		pass
	elif alive_players <= 0:
		# TODO: Error? Nobody left!
		pass
	if is_network_master():
		for body in $Level.get_children():
			for polygon in body.get_children():
				if polygon is Polygon2D:
					polygon.color = Color.white
