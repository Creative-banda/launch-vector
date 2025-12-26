extends CanvasLayer

@export var level_1: PackedScene


func _ready() -> void:
	FadeController.fade_out()

func _on_play_button_down() -> void:
	FadeController.fade_in()
	get_tree().change_scene_to_packed(level_1)

func _on_quit_button_down() -> void:
	FadeController.fade_in()
	get_tree().quit()
