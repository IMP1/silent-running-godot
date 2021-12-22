extends KinematicBody2D

const MAX_SPEED = 2
const ACCELLERATION = 1
const SPEED_EPSILON = 0.1
const DECELLERATION = 0.8
const TORPEDO_OFFSET = Vector2(0, 20)
const PING_OFFSET = 40
const IMPACT_BOUNCE = 0.3

export(Color) var passive_stealth = Color(1.0, 1.0, 1.0)
export(Color) var active_stealth = Color(0.0, 0.0, 0.0)
export(Color) var remote_stealth = Color("#212121")
export(int) var max_health : int = 100

var silent_running = false
var velocity : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(1, 0)
var health : int = max_health
var player_id : int = 0

puppet var remote_velocity: Vector2 = Vector2.ZERO setget update_remote_velocity
puppet var remote_position: Vector2 = position setget update_remote_position

onready var tween : Tween = $Tween
onready var game_scene : Node2D = null

func _ready() -> void:
	add_to_group("Player")

func start():
	health = max_health
	$HUD/GUI/HealthBar/Health.rect_size.x = $HUD/GUI/HealthBar.rect_size.x - 4
	$ActivePingTimer.start()
	$TorpedoTimer.start()
	if is_network_master():
		toggle_silent_running(silent_running)

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
		var collision : KinematicCollision2D = move_and_collide(velocity)
		if collision and not collision.collider.is_in_group("Ping"):
			if collision.collider.is_in_group("Torpdeo"):
				rpc("damage", collision.collider.DAMAGE)
				collision.collider.explode()
			else:
				velocity = velocity.bounce(collision.normal) * IMPACT_BOUNCE
				var damage = 40 # TODO: Determine damage somehow
				rpc("damage", damage)
	if movement_input == Vector2.ZERO:
		var decelleration = DECELLERATION
		if Input.is_action_pressed("move_brake"):
			decelleration /= 20
		velocity = lerp(velocity, velocity * decelleration, delta)
		if velocity.length_squared() <= SPEED_EPSILON * SPEED_EPSILON:
			velocity = Vector2.ZERO
	rset_unreliable("remote_position", position)
	rset_unreliable("remote_velocity", velocity)

func _unhandled_input(event):
	if not is_network_master():
		return
	if event.is_action_pressed("fire_torpedo") and $TorpedoTimer.time_left == 0:
		game_scene.rpc("add_torpedo", position + TORPEDO_OFFSET, direction)
		$TorpedoTimer.start()
	if event.is_action_pressed("toggle_silent_running"):
		toggle_silent_running(not silent_running)
	if event.is_action_pressed("active_ping") and $ActivePingTimer.time_left == 0:
		var mouse_pos = get_viewport().get_mouse_position()
		mouse_pos -= get_viewport_rect().size / 2
		var ping_dir = mouse_pos.normalized()
		game_scene.rpc("add_ping", position + ping_dir * PING_OFFSET, ping_dir)
		$ActivePingTimer.start()
	if event.is_action_pressed("use_secondary"):
		pass 
		# TODO: What is current secondary? Timer Mines, Proximity Mines, Decoy Mines, ...
		# TODO: Use whatever it is!
	# TODO: Remove debug map reveal
	if Input.is_action_pressed("cycle_secondary_forward"):
		var list : HBoxContainer = $HUD/GUI/Utilities/List
		var last = list.get_child(list.get_child_count() - 1)
		list.move_child(last, 0)
	if Input.is_action_pressed("cycle_secondary_backward"):
		var list : HBoxContainer = $HUD/GUI/Utilities/List
		var first = list.get_child(0)
		list.move_child(first, list.get_child_count() - 1)

func toggle_silent_running(on):
	if on:
		$Sprite.modulate = active_stealth
		$PassivePingTimer.stop()
	else:
		$Sprite.modulate = passive_stealth
		$PassivePingTimer.start()
		if game_scene:
			game_scene.rpc("add_sound", position, null, 15.0)
	silent_running = on

func update_gui():
	var progress = ($TorpedoTimer.wait_time - $TorpedoTimer.time_left) / $TorpedoTimer.wait_time
	$HUD/GUI/TubeProgress.material.set_shader_param("progress", progress)

func _process(delta: float) -> void:
	update_gui()
	if is_network_master():
		move_submarine(delta)
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

remotesync func damage(amount):
	health -= amount
	$HUD/GUI/HealthBar/Health.rect_size.x = ($HUD/GUI/HealthBar.rect_size.x - 4) * health / max_health
	if health <= 0:
		health = 0
		game_scene.rpc("player_died", self.player_id)
	$DamageAudio.play()
	# TODO: Add screenshake

func _on_PassivePingTimer():
	game_scene.rpc("add_sound", position, null, 15.0)
