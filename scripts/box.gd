extends RigidBody2D

@export var box_point: Vector2
var reset_state: bool = false

func _ready() -> void:
	box_point = global_position

func reset_position() -> void:
	await get_tree().create_timer(0.3).timeout
	# After the wait is done, trigger the reset flag
	
	reset_state = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if reset_state:
		state.transform.origin = box_point
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		reset_state = false
