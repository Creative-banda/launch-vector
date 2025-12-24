extends Node2D


@onready var barrel_1: Sprite2D = $barrel_1
@onready var barrel_1_animation: AnimatedSprite2D = $barrel_1_animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_active = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		animation_player.play("blink")

func on_blink_finished() -> void:
	if is_active:
		return
	is_active = true
	barrel_1_animation.visible = true
	# Select a random number between 1 and 3 
	var random_animation = randi() % 3 + 1
	barrel_1_animation.play("animation_" + str(random_animation))

func _on_barrel_1_animation_animation_finished() -> void:
	queue_free()

func _on_barrel_1_animation_frame_changed() -> void:
	var current_anim = barrel_1_animation.animation
	var current_frame = barrel_1_animation.frame
	
	# Disable barrel_1 sprite at specific frames based on animation
	if current_anim == "animation_3" and current_frame == 8:
		barrel_1.visible = false
	elif current_anim == "animation_2" and current_frame == 10:
		barrel_1.visible = false
	elif current_anim == "animation_1" and current_frame == 9:
		barrel_1.visible = false
