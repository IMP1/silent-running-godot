extends KinematicBody2D

const MAX_SPEED = 2
const ACCELLERATION = 1
const SPEED_EPSILON = 0.1
const DECELLERATION = 0.8
const TORPEDO_OFFSET = Vector2(0, 20)
const PING_OFFSET = 20

export(Color) var passive_stealth = Color(1.0, 1.0, 1.0)
export(Color) var active_stealth  = Color(0.0, 0.0, 0.0)

var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(1, 0)
export var silent_running = true setget toggle_silent_running

puppet var remote_velocity: Vector2 = Vector2.ZERO setget update_remote_velocity
puppet var remote_position: Vector2 = position setget update_remote_position

onready var tween : Tween = $Tween
onready var game_scene : Node2D = null

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
	if Input.is_action_just_pressed("toggle_silent_running"):
		toggle_silent_running(not silent_running)
	if Input.is_action_just_pressed("active_ping"):
		var ping_dir = Vector2(0.0, 0.0) # TODO: Get mouse direction from player
		game_scene.rpc("add_ping", position + ping_dir * PING_OFFSET, ping_dir)
	if Input.is_action_just_pressed("use_secondary"):
		pass 
		# TODO: What is current secondary? Timer Mines, Proximity Mines, Decoy Mines, ...
		# TODO: Use whatever it is!

func toggle_silent_running(on):
	if on:
		$Sprite.modulate = active_stealth
		$PassivePingTimer.stop()
	else:
		$Sprite.modulate = passive_stealth
		$PassivePingTimer.start()
	silent_running = on

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

func _on_PassivePingTimer():
	game_scene.rpc("add_sound", position)
