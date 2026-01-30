extends Node2D

@export var isSoundOn : bool = true

func _ready() -> void:
	if isSoundOn:
		$AudioStreamPlayer2D.play()
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(3)
	if body.has_method("reset_position"):
		body.call_deferred("reset_position")
