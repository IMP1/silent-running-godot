extends Node

signal fade_completed
signal finished

const TRANSITION_EXPONENTIAL = 5
const EASE_IN = 0
const EASE_OUT = 1

var fading = false

onready var track_1: AudioStreamPlayer = $Track1
onready var track_2: AudioStreamPlayer = $Track2
onready var tween: Tween = $Tween

func _ready():
	tween.connect("tween_all_completed", self, "_fade_completed")
	track_1.connect("finished", self, "_track_finished", [1])
	track_2.connect("finished", self, "_track_finished", [2])

func _track_finished(track_number):
	if fading:
		return
	if track_number == 1 and not track_2.playing:
		emit_signal("finished")
	elif track_number == 2 and not track_1.playing:
		emit_signal("finished")

func cross_fade_to(stream: AudioStream, duration: float = 0) -> void:
	if track_1.playing and track_2.playing:
		return
	var next_track: AudioStreamPlayer
	var prev_track: AudioStreamPlayer
	if track_1.playing:
		next_track = track_2
		prev_track = track_1
	else:
		next_track = track_1
		prev_track = track_2
	next_track.stream = stream
	next_track.play()
	next_track.volume_db = -80.0
	tween.interpolate_property(next_track, "volume_db", -80.0, 0.0, duration, TRANSITION_EXPONENTIAL, EASE_OUT)
	tween.interpolate_property(prev_track, "volume_db", 0.0, -80.0, duration, TRANSITION_EXPONENTIAL, EASE_IN)
	tween.start()
	fading = true

func _fade_completed():
	emit_signal("fade_completed")
	fading = false

func stop():
	track_1.stop()
	track_2.stop()

func play(stream: AudioStream):
	stop()
	track_1.stream = stream
	track_1.play()
