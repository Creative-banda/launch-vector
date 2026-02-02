extends CanvasLayer

var level_to_change: PackedScene



func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_play_button_up() -> void:
	level_to_change = preload("res://scenes/level_selector.tscn")
	FadeController.fade_in(level_to_change)
