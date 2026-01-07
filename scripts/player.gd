extends CharacterBody2D

# Export variables
@export var tileMap: TileMapLayer
@export var player_ui: CanvasLayer

# Constants for scenes
const MAIN_MENU_PATH = "res://scenes/main_menu.tscn"

# Instances
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var push_area: Area2D = $PushArea

# Constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK_VELOCITY = -400.0
const PUSH_FORCE = 1000.0
const KNOCKBACK_TIME = 0.5


# Variables
var last_knockback_time: float = 0.0
var hurt: bool = false
var life: int = 3
var is_active: bool = true
var collected_battery: int = 3

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	# Defer the UI update to ensure player_ui is ready
	if player_ui:
		player_ui.call_deferred("update_label", collected_battery)
	else:
		print("Warning: player_ui is not assigned!")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "hurt":
		hurt = false

func take_damage(damage: int = 1) -> void:
	if not is_active or hurt or Time.get_ticks_msec() / 1000.0 < last_knockback_time + KNOCKBACK_TIME:
		return

	velocity.y = KNOCKBACK_VELOCITY # Apply knockback jump
	last_knockback_time = Time.get_ticks_msec() / 1000.0
	if not hurt:
		hurt = true
		life -= damage
		player_ui.update_healthbar(life)
		if life <= 0:
			is_active = false
			animated_sprite.play("die")
			FadeController.fade_in()
			# Create a 0.5 second timer and on time out change scene to main menu
			get_tree().create_timer(1.5).connect("timeout", _on_death_timer_timeout)
		else:
			animated_sprite.play("hurt")

func _physics_process(delta: float) -> void:
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.8
	
	# Get player input
	var direction := Input.get_axis("left", "right")
	
	# Handle jump (only when not hurt)
	if not hurt and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
		AudioPlayer.play_music("jump")
	
	# Handle horizontal movement (allowed even when hurt)
	if direction and is_active:
		velocity.x = direction * SPEED
		if not hurt: # Only flip sprite when not hurt
			animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle animations
	if hurt:
		if animated_sprite.animation != "hurt" and life > 0:
			animated_sprite.play("hurt")
	elif not is_on_floor():
		if animated_sprite.animation != "jump":
			animated_sprite.play("jump")
	elif direction:
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	# Push any Rigid body

	for body in push_area.get_overlapping_bodies():
		if body is RigidBody2D:
			var dir = (body.global_position - global_position).normalized()
			body.apply_force(dir * PUSH_FORCE)

	move_and_slide()
	check_tile_damage()

func check_tile_damage():
	var local_pos := tileMap.to_local(global_position + Vector2(0, 8))
	var cell := tileMap.local_to_map(local_pos)
	var tile_data := tileMap.get_cell_tile_data(cell)

	if tile_data and tile_data.get_custom_data("damage") == 1:
		take_damage(1)

func update_battery(battery: int = 1) -> void:
	collected_battery += battery
	AudioPlayer.play_music("collect")
	player_ui.update_label(collected_battery)

func _on_death_timer_timeout() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
