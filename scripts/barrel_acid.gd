extends Node2D
@onready var barrel_2_gas: AnimatedSprite2D = $barrel_2_gas
@onready var barrel_2: Sprite2D = $barrel_2
@onready var barrel_2_animation: AnimatedSprite2D = $barrel_2_animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barrel_2_animation.visible = false
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		animation_player.play("barrel_blink")


func on_blink_finished() -> void:
	print("Blink finished")
	if is_active:
		return
	is_active = true
	barrel_2_animation.visible = true
	barrel_2_animation.play("default")

func _on_barrel_2_animation_frame_changed() -> void:
	print("Frame changed")
	# Get current frame
	var current_frame = barrel_2_animation.frame
	
	if current_frame == 16:
		barrel_2.visible = false
		barrel_2_gas.visible = true


func _on_barrel_2_animation_animation_finished() -> void:
	queue_free()
