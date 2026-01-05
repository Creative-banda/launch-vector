extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_in(next_scene: PackedScene = null) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)

func fade_out() -> void:
	animation_player.play("fade_out")
