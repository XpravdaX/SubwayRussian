extends StaticBody3D

class_name Interactable

signal interacted()

@export var prompt_message = "Нажмите что бы взаимодействовать"
@export var prompt_action = "interact"

func get_prompt():
	return prompt_message + "\n"
	
func interact(body):
	emit_signal("interacted")
