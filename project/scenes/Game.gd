extends Node2D

const BACKGROUND_MUSIC_TRACKS = [
	preload("res://audio/cinematic-space-drone.ogg"),
	preload("res://audio/deeper-into-the-void.ogg"),
	preload("res://audio/caves-of-dawn.ogg"),
]
const MUSIC_CROSS_FADE_TIME = 2.0

var alive_players : int = 0
var this_player_id : int = 0
var music_rng = RandomNumberGenerator.new()

onready var main = $"/root/Main"
onready var gui = $CanvasLayer/GUI
onready var world = $World
onready var torpedo_list = world.get_node("Torpedos")
onready var mine_list = world.get_node("Mines")
onready var player_list = world.get_node("Players")
onready var ping_list = world.get_node("Pings")
onready var sound_list = world.get_node("Sounds")
onready var level
onready var starting_positions
onready var player_camera: Camera2D
onready var music_timer: Timer = $MusicTimer

func _ready():
	music_rng.randomize()
	music_timer.connect("timeout", self, "_next_background_music")
	_next_background_music()
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	for placeholder_player in player_list.get_children():
		player_list.remove_child(placeholder_player)
	$Background/ColorRect.color = Constants.COLOUR_BACKGROUND
	$CanvasLayer/Menu.visible = false

func _next_background_music():
	var i = music_rng.randi_range(0, BACKGROUND_MUSIC_TRACKS.size() - 1)
	var next_track: AudioStream = BACKGROUND_MUSIC_TRACKS[i]
	main.music_manager.cross_fade_to(next_track, MUSIC_CROSS_FADE_TIME)
	var length = next_track.get_length()
	music_timer.start(length - MUSIC_CROSS_FADE_TIME)

func setup(game_settings):
	level = load("res://levels/" + str(game_settings["level"]) + ".tscn").instance()
	world.get_node("LevelContainer").add_child(level)
	starting_positions = level.get_node("StartingPositions")
	var player_positions = []
	for position in starting_positions.get_children():
		player_positions.append(position.position)
	randomize()
	player_positions.shuffle()
	
	this_player_id = game_settings["player_id"]
	var player_ids : Array = game_settings["player_ids"]
	for i in player_ids:
		var player_object : KinematicBody2D = load("objects/Player.tscn").instance()
		player_list.add_child(player_object)
		player_object.game_scene = self
		player_object.player_id = i
		player_object.set_name("Player " + str(i))
		player_object.set_network_master(i)
		player_object.position = player_positions.pop_back()
		if i == this_player_id:
			var camera = Camera2D.new()
			player_object.add_child(camera)
			camera.current = true
			Screenshake.camera = camera
			player_camera = camera
		else:
			player_object.get_node("HUD/GUI").visible = false
			player_object.get_node("Sprite").modulate = player_object.remote_stealth
		player_object.start()
	alive_players = player_ids.size()
	hide_map()

func _server_disconnected():
	print("Lost server connection!\n")
	gui.find_node("GameStatus").text = "Connection Lost"

func _player_disconnected(id):
	# TODO: Inform the game somehow
	#       Show text in GameStatus (and fade out after a bit?)
	#       Have a chat function and show it in there?
	print("Disconnect!")
	print(id)
	print("\n")

func get_player(player_id):
	return player_list.find_node("Player " + str(player_id))

func _input(event):
	if event.is_action_pressed("open_menu"):
		$CanvasLayer/Menu.visible = not $CanvasLayer/Menu.visible
	if event.is_action_pressed("cheat"):
		reveal_map()

remotesync func add_torpedo(position, direction):
	var torpedo = load("res://objects/Torpedo.tscn").instance()
	torpedo_list.add_child(torpedo)
	torpedo.game_scene = self
	torpedo.position = position
	torpedo.direction = direction

remotesync func add_sound(position, sound_source = "ping", size = 10.0):
	var sound: Node2D = load("res://objects/Sound.tscn").instance()
	sound_list.add_child(sound)
	if sound_source:
		sound.audio.stream = load("res://audio/" + sound_source + ".ogg")
	else:
		sound.audio.stream = null
	sound.size = size
	sound.global_position = position
	sound.start()

remotesync func add_ping(position, direction):
	var ping = load("res://objects/Ping.tscn").instance()
	ping_list.add_child(ping)
	ping.game_scene = self
	ping.position = position
	ping.direction = direction
	ping.start()

remotesync func add_mine(position, mine_type):
	var mine = load("res://objects/" + mine_type + ".tscn").instance()
	mine_list.add_child(mine)
	mine.game_scene = self
	mine.position = position
	mine.start()

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
		get_player(player_id).find_node("Sprite").modulate = Constants.COLOUR_DEATH

func hide_map():
	$Background/ColorRect.color = Constants.COLOUR_BACKGROUND
	for body in level.get_node("Rocks").get_children():
		for polygon in body.get_children():
			if polygon is Polygon2D:
				polygon.color = Constants.COLOUR_BACKGROUND

func reveal_map():
	for body in level.get_node("Rocks").get_children():
		for polygon in body.get_children():
			if polygon is Polygon2D:
				polygon.color = Constants.COLOUR_VISIBLE
	for player in player_list.get_children():
		player.find_node("Sprite").modulate = Constants.COLOUR_VISIBLE
		if player.health <= 0:
			player.find_node("Sprite").modulate = Constants.COLOUR_DEATH
