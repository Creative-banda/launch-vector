extends Node2D


func _ready() -> void:
	print("Dust particles ready")



func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
