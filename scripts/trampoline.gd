extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		body.velocity.y = body.JUMP_VELOCITY * 1.5
		$AnimatedSprite2D.play("jump")
		AudioPlayer.play_music("trampoline")
