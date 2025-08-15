extends Area3D

@export var labelTime: Label
var timer: float = 0.0
var is_counting: bool = true

func _on_body_entered(body):
	timer = 0.0
	is_counting = true
	update_time_label()


func _process(delta):
	if is_counting:
		timer += delta
		update_time_label()

func update_time_label():
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	labelTime.text = "%01d:%02d" % [minutes, seconds]
