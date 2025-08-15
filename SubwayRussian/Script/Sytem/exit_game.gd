extends Area3D
class_name ExitGame

@export var target_scene_path: String = "res://Scene/load_scene_game_exit.tscn"

func _on_body_entered(body):
	if body.is_in_group("player") or body is CharacterBody3D:
		var target_scene = load(target_scene_path)
		if target_scene:
			get_tree().change_scene_to_packed(target_scene)
		else:
			print("Ошибка: не удалось загрузить сцену по пути ", target_scene_path)
