extends Node2D

@onready var background_music: AudioStreamPlayer = $Background_music
@onready var jump: AudioStreamPlayer = $Jump
@onready var collect: AudioStreamPlayer = $Collect

func play_music(music: String) -> void:
	if music == "background":
		background_music.play()
	elif music == "jump":
		jump.play()
	elif music == "collect":
		collect.play()

func stop_all_music() -> void:
	background_music.stop()
	jump.stop()
	collect.stop()
