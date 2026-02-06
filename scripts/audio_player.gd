extends Node2D

@onready var background_music: AudioStreamPlayer = $Background_music
@onready var jump: AudioStreamPlayer = $Jump
@onready var collect: AudioStreamPlayer = $Collect
@onready var trampoline: AudioStreamPlayer = $Trampoline
@onready var hurt1: AudioStreamPlayer = $Hurt1
@onready var hurt2: AudioStreamPlayer = $Hurt2
@onready var hurt3: AudioStreamPlayer = $Hurt3
@onready var game_over: AudioStreamPlayer = $Game_over
@onready var main_menu: AudioStreamPlayer = $Main_Menu_Background_music

func play_music(music: String) -> void:
	if music == "background":
		background_music.play()
	elif music == "jump":
		jump.play()
	elif music == "collect":
		collect.play()
	elif music == "trampoline":
		trampoline.play()
	elif music == "hurt":
		[hurt1, hurt2, hurt3].pick_random().play()
	elif music == "game_over":
		game_over.play()
	elif music == "main_menu":
		main_menu.play()

func stop_all_music() -> void:
	background_music.stop()
	jump.stop()
	collect.stop()
	trampoline.stop()
	hurt1.stop()
	hurt2.stop()
	hurt3.stop()
	game_over.stop()
	main_menu.stop()
