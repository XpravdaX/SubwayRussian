# RayCast3D скрипт
extends RayCast3D

@onready var prompt_label = $"../../Control/Prompt"
var current_interactable: Interactable = null

func _process(delta: float) -> void:
	if not is_colliding():
		current_interactable = null
		prompt_label.text = ""
		return
	
	var collider = get_collider()
	if collider is Interactable:
		current_interactable = collider
		prompt_label.text = collider.get_prompt()
		
		if Input.is_action_just_pressed(collider.prompt_action):
			collider.interact(owner)
	else:
		current_interactable = null
		prompt_label.text = ""

func mobile_interact():
	if current_interactable:
		current_interactable.interact(owner)
