extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Start with layer below everything so it doesn't block input
	layer = -1

func fade_in(next_scene: PackedScene = null) -> void:
	# Move to top layer during fade
	layer = 100
	animation_player.play("fade_in")
	await animation_player.animation_finished
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	# Move back down after fade (though scene will change anyway)
	layer = -1

func fade_out() -> void:
	# Move to top layer during fade
	layer = 100
	animation_player.play("fade_out")
	await animation_player.animation_finished
	# Move back down after fade completes
	layer = -1
