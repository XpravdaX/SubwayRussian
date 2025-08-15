extends PathFollow3D
class_name PravdaSempai_TrainWagon

@export var rail: Path3D

var current_speed: float = 0.0 
var follow_distance: float = 5.0

@export var target_train: PravdaSempai_Train

func _ready():
	if not get_parent() is Path3D:
		call_deferred("connect_to_rail")

func _physics_process(delta):
	if target_train:
		current_speed = target_train.current_speed  

	progress += current_speed * delta

func connect_to_rail():
	if rail == null:
		if get_parent() is Path3D:
			rail = get_parent()
		else:
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
