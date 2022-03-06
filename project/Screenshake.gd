extends Node

var rumble_strength: Vector2 = Vector2.ZERO
var shakes: Dictionary = {}

onready var camera: Camera2D

func add_screen_rumble(velocity: Vector2) -> void:
	rumble_strength += velocity

func add_screen_shake(duration: float, velocity: Vector2) -> void:
	var node = Node.new()
	add_child(node)
	var timer = Timer.new()
	node.add_child(timer)
	timer.start(duration)
	timer.connect("timeout", self, "_remove_screen_shake", [node])
	shakes[node] = velocity

func _remove_screen_shake(node: Node) -> void:
	remove_child(node)
	node.queue_free()
	shakes.erase(node)

func _process(delta):
	var total_shake = rumble_strength
	for shake_node in shakes:
		total_shake += shakes[shake_node]
	if camera:
		camera.offset = randf() * total_shake * 2 - total_shake
