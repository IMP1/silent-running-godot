extends Node2D

export(float, 0, 10, 0.1) var duration = 1.0
export var size : float = 10.0

var started : bool = false
var world_viewport: Viewport

onready var animation : AnimationPlayer = $AnimationPlayer
onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
onready var tween : Tween = $Tween

func start(world: Viewport):
	world_viewport = world
	if audio.stream:
		audio.play()
		duration = audio.stream.get_length()
	tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(size, size), duration)
	tween.interpolate_property(self, "modulate", Color.white, Color(1, 1, 1, 0), duration)
	tween.start()
	tween.connect("tween_all_completed", self, "stop")
	$BackBufferCopy/Polygon2D.material.set_shader_param("world", world_viewport.get_texture())
	started = true

func _process(delta):
	if started:
		$BackBufferCopy/Polygon2D.material.set_shader_param("world", world_viewport.get_texture())

func stop():
	queue_free()
