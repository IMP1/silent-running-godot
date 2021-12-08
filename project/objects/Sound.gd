extends Node2D

onready var animation : AnimationPlayer = $AnimationPlayer
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D

func start():
	animation.play("Grow")
	audio.play()

func stop():
	queue_free()
