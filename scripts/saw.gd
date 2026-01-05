extends Node2D

@export var speed := 1.0
@export var damage := 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Rotate the saw into position
	rotation += speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
