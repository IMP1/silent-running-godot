extends Node2D

onready var animation : AnimationPlayer = $AnimationPlayer
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var tween : Tween = $Tween

export var size : float = 10.0

func start():
	tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(size, size), 1.0)
	animation.play("Grow")
	if audio.stream:
		audio.play()
	tween.start()

func stop():
	queue_free()
