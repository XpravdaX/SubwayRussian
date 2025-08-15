extends Label

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_update_time)
	timer.start(1.0)
	_update_time()

func _update_time():
	var time_dict = Time.get_time_dict_from_system()
	var time_string = "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]
	text = time_string
