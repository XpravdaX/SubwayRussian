extends PathFollow3D
class_name PravdaSempai_Train

@export var rail: Path3D

@export_category("AI")
@export var aI: bool = true

@export_category("Поезд")
@export var max_speed: float = 15.0
@export var acceleration: float = 1.0
@export var deceleration: float = 1.55
@export var loops: bool = true

@export_category("Двери")
@export var leftDoor1: Array[Node3D]
@export var leftDoor2: Array[Node3D]

@export var rightDoor1: Array[Node3D]
@export var rightDoor2: Array[Node3D]

@export var leftOpen: bool
@export var rightOpen: bool
@export var doorSpeed: float = 1.0 
@export var doorOpenAmount: float = 0.7

@export_category("Звуки поезда")
@export var audioSourceTrain: AudioStreamPlayer3D
@export var audioSourceRun: AudioStream
@export var audioSourceIdle: AudioStream
@export var max_run_volume: float = 1.8 
@export var volume_change_speed: float = 0.5

@export_category("Звуки дверей")
@export var audioSourceDoor: AudioStreamPlayer3D
@export var audioSourceDoorOpen: AudioStream
@export var audioSourceDoorClose: AudioStream

@export_category("Вагоны")
@export var wagon: Array[PravdaSempai_TrainWagon]

@export_category("Ручное управление")
@export var manual_control: bool = false
@export var target_speed_ratio: float = 0.0 

var current_speed: float = 0.0
@export var is_moving: bool = true
# Храним исходные позиции дверей
var doorInitialPositions: Dictionary = {}
var target_volume: float = 0.0
var current_train_sound: AudioStream = null

func _ready():
	if not get_parent() is Path3D:
		call_deferred("connect_to_rail")

	add_to_group("trainPS")
	save_initial_door_positions()

func connect_to_rail():
	if rail == null:
		if get_parent() is Path3D:
			rail = get_parent()
		else:
			push_warning("Train should be a child of a Path3D node or have rail property set")
			return

	if get_parent() == rail:
		return

	var global_pos = global_transform.origin

	var old_parent = get_parent()
	if old_parent:
		old_parent.remove_child(self)
	rail.add_child(self)
	global_transform.origin = global_pos
	var curve = rail.curve
	if curve:
		var points = []
		for i in range(curve.point_count):
			points.append(curve.get_point_position(i) + rail.global_transform.origin)
		var closest_point = global_pos
		var min_dist = INF
		var closest_offset = 0.0
		for i in range(curve.point_count - 1):
			var segment_start = points[i]
			var segment_end = points[i + 1]
			var closest = Geometry3D.get_closest_point_to_segment(global_pos, segment_start, segment_end)
			var dist = closest.distance_to(global_pos)
			
			if dist < min_dist:
				min_dist = dist
				closest_point = closest
		progress = curve.get_closest_offset(closest_point - rail.global_transform.origin)
	progress = max(progress, 0.0)
	progress_ratio = progress / rail.curve.get_baked_length() if rail.curve else 0.0

func _physics_process(delta):
	if manual_control:
		handle_manual_control(delta)
	else:
		handle_ai_control(delta)
	move_train(delta)
	handle_doors(delta)
	update_train_sounds(delta)

func handle_ai_control(delta):
	if not is_moving:
		current_speed = max(current_speed - deceleration * delta, 0.0)
	else:
		current_speed = min(current_speed + acceleration * delta, max_speed)

func handle_manual_control(delta):
	var target_speed = target_speed_ratio * max_speed
	
	if current_speed < target_speed:
		current_speed = min(current_speed + acceleration * delta, target_speed)
	elif current_speed > target_speed:
		current_speed = max(current_speed - deceleration * delta, target_speed)

func move_train(delta):
	progress += current_speed * delta
	if progress_ratio >= 1.0:
		if loops:
			progress = 0.0
		else:
			is_moving = false

func save_initial_door_positions():
	for door in leftDoor1 + leftDoor2 + rightDoor1 + rightDoor2:
		if door != null:
			doorInitialPositions[door] = door.position

func handle_doors(delta):
	handle_door_group(leftDoor1, leftOpen, Vector3(0, 0, doorOpenAmount), delta)
	handle_door_group(leftDoor2, leftOpen, Vector3(0, 0, -doorOpenAmount), delta)
	
	handle_door_group(rightDoor1, rightOpen, Vector3(0, 0, doorOpenAmount), delta)
	handle_door_group(rightDoor2, rightOpen, Vector3(0, 0, -doorOpenAmount), delta)

func handle_door_group(doors: Array[Node3D], should_open: bool, target_offset: Vector3, delta):
	for door in doors:
		if door == null:
			continue
		var initial_pos = doorInitialPositions.get(door, door.position)
		var target_pos = initial_pos + target_offset if should_open else initial_pos
		door.position = door.position.move_toward(target_pos, doorSpeed * delta)

func play_door_sound(is_opening: bool):
	if audioSourceDoor == null:
		return
	
	if is_opening && audioSourceDoorOpen != null:
		audioSourceDoor.stream = audioSourceDoorOpen
		audioSourceDoor.play()
	elif !is_opening && audioSourceDoorClose != null:
		audioSourceDoor.stream = audioSourceDoorClose
		audioSourceDoor.play()

func update_train_sounds(delta):
	if audioSourceTrain == null:
		return

	var target_stream: AudioStream
	if current_speed > 0.1:
		target_stream = audioSourceRun
		target_volume = max_run_volume * (current_speed / max_speed * 20)
	else:
		target_stream = audioSourceIdle
		target_volume = 1.0

	if current_train_sound != target_stream:
		current_train_sound = target_stream
		audioSourceTrain.stream = target_stream
		audioSourceTrain.play()

	audioSourceTrain.volume_db = lerp(
		audioSourceTrain.volume_db, 
		linear_to_db(target_volume), 
		volume_change_speed * delta
	)
