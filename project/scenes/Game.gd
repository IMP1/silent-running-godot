extends Node2D

const player_script = preload("res://objects/Player.gd")

var alive_players : int = 0
var this_player_id : int = 0

onready var gui = $CanvasLayer/GUI

func setup(game_settings):
	# TODO: Procedural Level Generation
	var player_positions = []
	player_positions.append(Vector2(400, 200))
	player_positions.append(Vector2(1500, 1200))
	# TODO: Randomise player positions
	
	this_player_id = game_settings["player_id"]
	var player_ids : Array = game_settings["player_ids"]
	for i in player_ids:
		var player_object : KinematicBody2D = load("objects/Player.tscn").instance()
		$Players.add_child(player_object)
		player_object.game_scene = self
		player_object.player_id = i
		player_object.set_name("Player " + str(i))
		player_object.set_network_master(i)
		player_object.position = player_positions.pop_back()
		if i == this_player_id:
			var camera = Camera2D.new()
			player_object.add_child(camera)
			camera.current = true
		else:
			player_object.get_node("HUD/GUI").visible = false
			player_object.get_node("Sprite").modulate = player_object.remote_stealth
		player_object.start()
	alive_players = player_ids.size()

func _ready():
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	$CanvasLayer/Menu.visible = false

func _server_disconnected():
	print("Lost server connection!\n")
	gui.find_node("GameStatus").text = "Connection Lost"

func _player_disconnected(args):
	print("Disconnect!")
	print(args)
	print("\n")

func get_player(player_id):
	return $Players.find_node("Player " + str(player_id))

func _input(event):
	if event.is_action_pressed("open_menu"):
		$CanvasLayer/Menu.visible = not $CanvasLayer/Menu.visible

remotesync func add_torpedo(position, direction):
	var torpedo = load("res://objects/Torpedo.tscn").instance()
	$Torpedos.add_child(torpedo)
	torpedo.game_scene = self
	torpedo.position = position
	torpedo.direction = direction

remotesync func add_sound(position, sound_source = "ping", size = 10.0):
	var sound = load("res://objects/Sound.tscn").instance()
	$Sounds.add_child(sound)
	if sound_source:
		sound.audio.stream = load("res://audio/" + sound_source + ".ogg")
	else:
		sound.audio.stream = null
	sound.size = size
	sound.position = position
	sound.start()

remotesync func add_ping(position, direction):
	var ping = load("res://objects/Ping.tscn").instance()
	$Pings.add_child(ping)
	ping.game_scene = self
	ping.position = position
	ping.direction = direction
	ping.start()

remotesync func player_died(player_id):
	alive_players -= 1
	if alive_players == 1 and player_id != this_player_id:
		gui.find_node("GameStatus").text = "You Win!"
	elif alive_players <= 0:
		gui.find_node("GameStatus").text = "Game Over"
	if player_id == this_player_id:
		reveal_map()
		gui.find_node("GameStatus").text = "Game Over"
	elif get_player(this_player_id).health <= 0:
		get_player(player_id).find_node("Sprite").modulate = Color.red

func reveal_map():
	for body in $Level.get_children():
		for polygon in body.get_children():
			if polygon is Polygon2D:
				polygon.color = Color.white
	for player in $Players.get_children():
		player.find_node("Sprite").modulate = Color.white
		if player.health <= 0:
			player.find_node("Sprite").modulate = Color.red
