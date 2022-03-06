extends "res://objects/Mine.gd"

export(float, 0, 10, 0.1) var time_delay = 3.0

func start():
	$Timer.connect("timeout", self, "ping")
	$Timer.start(time_delay)
	$Timer.one_shot = false

func ping():
	game_scene.add_sound(position, "ping", 15.0)
