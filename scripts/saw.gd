extends Node2D

@export var damage := 1
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var is_moving := false
@export var left_marker: Marker2D
@export var right_marker: Marker2D
@export var speed: int = 40

func _ready() -> void:
	audio_stream_player_2d.play()


func _process(_delta: float) -> void:
	if not is_moving:
		return
	
	# Check if markers are assigned before using them
	if not left_marker or not right_marker:
		push_warning("Saw markers not assigned! Please assign left_marker and right_marker in the editor.")
		return
	
	# Determine target based on current direction
	var target_x = right_marker.position.x if speed > 0 else left_marker.position.x
	
	# Move towards target
	position.x = move_toward(position.x, target_x, abs(speed) * _delta)
	
	# Reverse direction when reaching either marker
	if position.x == right_marker.position.x or position.x == left_marker.position.x:
		speed = - speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
