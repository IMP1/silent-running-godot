extends "res://objects/Mine.gd"
class_name ExplosiveMine

const DAMAGE = 100

func _ready():
	._ready()
	add_to_group("ExplosiveMine")

func activate():
	game_scene.rpc("add_sound", position, "clunk", 3.0)

func explode():
	game_scene.rpc("add_sound", position, "impact", 40.0)
	queue_free()
