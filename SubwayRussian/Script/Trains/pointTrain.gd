extends Area3D
class_name PointTrain

@export var train: PravdaSempai_Train
@export var timerStopTrain: Timer
@export var timerDoor: Timer

var doors_opened: bool = false

func _on_body_entered(body):
	stop_train()

func stop_train():
	train.is_moving = false
	if timerDoor.is_stopped() == false:
		timerDoor.stop()
	if timerStopTrain.is_stopped() == false:
		timerStopTrain.stop()
	var stop_check_timer = Timer.new()
	add_child(stop_check_timer)
	stop_check_timer.wait_time = 0.1
	stop_check_timer.one_shot = false
	
	stop_check_timer.timeout.connect(
		func():
			if train.current_speed <= 0.01:
				stop_check_timer.stop()
				stop_check_timer.queue_free()
				open_doors()
	)
	stop_check_timer.start()

func open_doors():
	train.leftOpen = true
	train.play_door_sound(true)
	doors_opened = true
	timerDoor.start()

func close_doors():
	train.leftOpen = false
	train.play_door_sound(false)
	doors_opened = false
	timerStopTrain.start()

func _on_timer_door_timeout():
	if doors_opened:
		close_doors()

func _on_timer_stop_train_timeout():
	start_train()

func start_train():
	train.is_moving = true
