extends MeshInstance3D

@export var anim: AnimationPlayer
var is_open := false

func _on_static_body_3d_interacted():
	if not anim:
		return
	
	if is_open:
		anim.play("close_door")
	else:
		anim.play("open_door")
	
	is_open = !is_open
