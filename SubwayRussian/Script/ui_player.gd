extends CanvasLayer
class_name UI_Mobile

@export var player: Player
@export var raycast: RayCast3D
@export var train_player: PravdaSempai_Train
@export var ui_player: Control
@export var ui_player_train: Control
@export var speed_text: Label
@export var slider: VSlider

func _ready():
	ui_player_train.visible = false
	ui_player.visible = true
	if slider:
		slider.max_value = 100
		slider.value = 0

func _process(delta):
	update_ui()

func update_ui():
	if speed_text and train_player:
		var speed_kmh = train_player.current_speed * 3.6
		speed_text.text = "Скорость: %.1f км/ч" % speed_kmh

func _on_v_slider_value_changed(value):
	if train_player:
		train_player.target_speed_ratio = value / 100.0
		if value > 0 and not train_player.manual_control:
			train_player.manual_control = true


func _on_manual_control_check_box_toggled(toggled_on):
	if train_player:
		train_player.manual_control = toggled_on
		if not toggled_on:
			train_player.target_speed_ratio = 0.0
			if slider:
				slider.value = 0

func _on_jump_pressed():
	player.mobile_jump()

func _on_hands_pressed():
	if raycast:
		raycast.mobile_interact()

func _on_left_door_check_box_toggled(toggled_on):
	if train_player:
		train_player.leftOpen = toggled_on
		train_player.play_door_sound(toggled_on)

func _on_right_door_check_box_toggled(toggled_on):
	if train_player:
		train_player.rightOpen = toggled_on
		train_player.play_door_sound(toggled_on)
