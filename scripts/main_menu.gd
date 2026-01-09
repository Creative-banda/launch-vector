extends Node2D

var level_to_change: PackedScene

func _ready() -> void:
	FadeController.fade_out()


func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_play_button_up() -> void:
	if GlobalManager.current_level == 1:
		level_to_change = preload("res://scenes/level_1.tscn")
	else:
		level_to_change = preload("res://scenes/level_2.tscn")
	FadeController.fade_in(level_to_change)
