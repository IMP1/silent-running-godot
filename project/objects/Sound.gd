extends Node2D

export(float, 0, 10, 0.1) var duration = 1.0

onready var animation : AnimationPlayer = $AnimationPlayer
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var tween : Tween = $Tween

export var size : float = 10.0

func start():
	if audio.stream:
		audio.play()
		duration = audio.stream.get_length()
	tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(size, size), duration)
	tween.interpolate_property(self, "modulate", Color.white, Color(1, 1, 1, 0), duration)
	tween.start()
	tween.connect("tween_all_completed", self, "stop")

func stop():
	queue_free()
