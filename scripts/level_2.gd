extends Node2D


func _ready() -> void:
	FadeController.fade_out()
	if AudioPlayer.background_music.is_playing():
		return
	AudioPlayer.play_music("background")
