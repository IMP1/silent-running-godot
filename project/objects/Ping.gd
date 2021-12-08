extends KinematicBody2D

export var speed = 10
export var bounces = 4
export var trail_length = 40

var direction : Vector2 = Vector2.ZERO
var remaining_bounces : int = 0
var bounce_positions : Array = []

onready var game_scene : Node2D = null
onready var trail : Line2D = $Line2D

func _ready():
	remaining_bounces = bounces

func start():
	bounce_positions.insert(0, position)

func _process(delta):
	var collision : KinematicCollision2D = move_and_collide(direction * speed)
	if collision:
		game_scene.rpc("add_sound", position)
		direction = direction.bounce(collision.normal)
		bounce_positions.insert(0, position)
		remaining_bounces -= 1
		if remaining_bounces <= 0:
			queue_free()
	update_trail()

func update_trail():
	var remaining_trail : float = trail_length
	trail.clear_points()
	trail.add_point(Vector2.ZERO)
	var last_pos : Vector2 = position
	for pos in bounce_positions:
		var segment : Vector2 = pos - last_pos
		var distance : float = segment.length()
		if distance > remaining_trail:
			trail.add_point(last_pos - position + segment.normalized() * remaining_trail)
			break
		else:
			trail.add_point(segment)
			remaining_trail -= distance
		last_pos = pos
