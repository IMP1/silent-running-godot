extends Node2D

export(float, 0, 10, 0.1) var duration = 1.0
export var size : float = 10.0

var started : bool = false

onready var animation : AnimationPlayer = $AnimationPlayer
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var tween : Tween = $Tween

func start():
	if audio.stream:
		audio.play()
		duration = audio.stream.get_length()
	tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(size, size), duration)
	tween.interpolate_property(self, "modulate", Color.white, Color(1, 1, 1, 0), duration)
	tween.interpolate_property($Light2D, "energy", 1, 0, duration * 2)
	tween.start()
	tween.connect("tween_all_completed", self, "stop")
	started = true

func stop():
	queue_free()
