extends Area3D

@export var ui: UI_Mobile
@export var player: Player

func _on_body_entered(body):
	if body == player:
		if ui: 
			ui.ui_player_train.visible = true
			ui.ui_player.visible = false


func _on_body_exited(body):
	if body == player:
		if ui: 
			ui.ui_player_train.visible = false
			ui.ui_player.visible = true
