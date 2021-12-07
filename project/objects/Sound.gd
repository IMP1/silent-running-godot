extends Node2D

onready var animation = $AnimationPlayer

func start():
	animation.play("Grow")
	# TODO: Play sound

func stop():
	queue_free()
