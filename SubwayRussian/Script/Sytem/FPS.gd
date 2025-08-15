extends Label

func _process(_delta):
	text = "FPS: %d" % Engine.get_frames_per_second()
