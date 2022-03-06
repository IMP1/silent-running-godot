extends "res://objects/Mine.gd"

const DAMAGE = 100

func start():
	add_to_group("ExplosiveMine")

func explode():
	game_scene.rpc("add_sound", position, "impact")
	queue_free()
