extends Node2D
@onready var barrel_2_gas: AnimatedSprite2D = $barrel_2_gas
@onready var barrel_2: Sprite2D = $barrel_2
@onready var barrel_2_animation: AnimatedSprite2D = $barrel_2_animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D2

var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	barrel_2_animation.visible = false

func _process(_delta: float) -> void:
	if is_active:
		check_if_someone_inside()

func check_if_someone_inside():
	var bodies = area.get_overlapping_bodies()
	if bodies.size() > 0:
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player":
		animation_player.play("barrel_blink")

func on_blink_finished() -> void:
	if is_active:
		return
	is_active = true
	barrel_2_animation.visible = true
	barrel_2_animation.play("default")
	$AudioStreamPlayer2D.play()
	animation_player.play("blast_collision")

func _on_barrel_2_animation_frame_changed() -> void:
	var current_frame = barrel_2_animation.frame
	
	if current_frame == 25:
		barrel_2.visible = false
		barrel_2_gas.visible = false
		$StaticBody2D/CollisionShape2D.disabled = true

func _on_barrel_2_animation_animation_finished() -> void:
	queue_free()
