extends KinematicBody2D

const MAX_SPEED = 2
const ACCELLERATION = 1
const SPEED_EPSILON = 0.1
const DECELLERATION = 0.8
const TORPEDO_OFFSET = Vector2(0, 20)

onready var tween : Tween = $Tween
onready var game_scene : Node2D = null

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(1, 0)

puppet var remote_velocity: Vector2 = Vector2.ZERO setget update_remote_velocity
puppet var remote_position: Vector2 = position setget update_remote_position

func _ready() -> void:
	pass

func move_submarine(delta: float):
	var movement_input : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		movement_input -= Vector2(0, 1)
	if Input.is_action_pressed("move_down"):
		movement_input += Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		movement_input -= Vector2(1, 0)
	if Input.is_action_pressed("move_right"):
		movement_input += Vector2(1, 0)
	if movement_input != Vector2.ZERO:
		velocity += movement_input.normalized() * delta * ACCELLERATION
		if velocity.length_squared() > MAX_SPEED * MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
		if movement_input.x > 0:
			direction = Vector2(1, 0)
		elif movement_input.x < 0:
			direction = Vector2(-1, 0)
	if (direction.x < 0) != ($Sprite.scale.x < 0):
		$Sprite.scale.x *= -1
	if velocity != Vector2.ZERO:
		position += velocity
		# TODO: Handle collisions
	if movement_input == Vector2.ZERO:
		velocity = lerp(velocity, velocity * DECELLERATION, delta)
		if velocity.length_squared() <= SPEED_EPSILON * SPEED_EPSILON:
			velocity = Vector2.ZERO
	rset_unreliable("remote_position", position)
	rset_unreliable("remote_velocity", velocity)

func use_abilities(delta: float) -> void:
	if Input.is_action_just_pressed("fire_torpedo"):
		game_scene.rpc("add_torpedo", position + TORPEDO_OFFSET, direction)

func _process(delta: float) -> void:
	if is_network_master():
		move_submarine(delta)
		use_abilities(delta)
	else:
		position += remote_velocity # Guess from last known velocity

func update_remote_position(new_pos: Vector2) -> void:
	remote_position = new_pos
	tween.interpolate_property(self, "position", position, remote_position, 0.1)
	tween.start()

func update_remote_velocity(new_vel: Vector2) -> void:
	remote_velocity = new_vel
	if (new_vel.x < 0) != ($Sprite.scale.x < 0):
		$Sprite.scale.x *= -1
