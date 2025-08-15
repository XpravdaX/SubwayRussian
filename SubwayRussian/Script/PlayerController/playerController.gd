extends CharacterBody3D
class_name Player

@export var WALK_SPEED = 5.0
@export var SPRINT_SPEED = 8.0
@export var JUMP_VELOCITY = 4.8
@export var SENSITIVITY = 0.004

var gravity = 9.8
var current_speed = WALK_SPEED

@export var joystick: Joystick
var joystick_active = false

@export var raycast: RayCast3D
var moving_platform_velocity = Vector3.ZERO
var current_platform: Node3D = null
var platform_velocity_smoothing = 0.9
var mouse_captured = true

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("ctrl"):
		mouse_captured = !mouse_captured
		update_mouse_mode()
	
	if mouse_captured and event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))


func update_mouse_mode():
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	update_platform_movement(delta)

	handle_movement(delta)
	handle_jump()
	handle_sprint()

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

	if is_on_floor() and current_platform:
		var platform_movement = current_platform.global_transform.origin - current_platform.get_meta("last_position", current_platform.global_transform.origin)
		global_transform.origin += platform_movement
		current_platform.set_meta("last_position", current_platform.global_transform.origin)

func update_platform_movement(delta):
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		current_platform = find_path_follow_parent(collider)
		
		if current_platform:
			if not current_platform.has_meta("last_position"):
				current_platform.set_meta("last_position", current_platform.global_transform.origin)

			var new_platform_velocity = (current_platform.global_transform.origin - current_platform.get_meta("last_position")) / delta
			moving_platform_velocity = moving_platform_velocity.lerp(new_platform_velocity, 1.0 - platform_velocity_smoothing)
	else:
		current_platform = null
		moving_platform_velocity = Vector3.ZERO

func find_path_follow_parent(node: Node) -> PathFollow3D:
	var current = node
	while current:
		if current is PathFollow3D:
			return current
		current = current.get_parent()
	return null

func handle_movement(delta):
	var input_dir = Input.get_vector("D", "A", "S", "W")
	
	if joystick and joystick.posVector != Vector2.ZERO:
		input_dir = -joystick.posVector
		joystick_active = true
	else:
		joystick_active = false
	
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 10.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 10.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 3.0)

func handle_jump():
	if (Input.is_action_just_pressed("Space") or joystick_active and Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		moving_platform_velocity = Vector3.ZERO

func handle_sprint():
	if Input.is_action_pressed("Sprint") or (joystick_active and Input.is_action_pressed("ui_select")):
		current_speed = SPRINT_SPEED
	else:
		current_speed = WALK_SPEED

func mobile_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		moving_platform_velocity = Vector3.ZERO
