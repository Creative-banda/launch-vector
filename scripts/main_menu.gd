extends CanvasLayer

var level_to_change: PackedScene

func _ready() -> void:
	FadeController.fade_out()

func _on_play_button_down() -> void:
	FadeController.fade_in()
	if GlobalManager.current_level == 1:
		level_to_change = preload("res://scenes/level_1.tscn")
	else:
		level_to_change = preload("res://scenes/level_2.tscn")

	get_tree().change_scene_to_packed(level_to_change)

func _on_quit_button_down() -> void:
	FadeController.fade_in()
	get_tree().quit()
