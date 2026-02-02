extends CharacterBody2D

# Export variables
@export var tileMap: TileMapLayer
@export var player_ui: CanvasLayer
# Constants for scenes
const MAIN_MENU_PATH = "res://scenes/level_selector.tscn"

# Instances
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var push_area: Area2D = $PushArea
@onready var jump_timer : Timer = $Timer
const DUST_PARTICALS = preload("res://scenes/dust_particals.tscn")

# Movement Constants
const SPEED = 300.0
const ACCELERATION = 1800.0  # How fast we reach max speed
const FRICTION = 1200.0  # How fast we stop
const AIR_ACCELERATION = 1200.0  # Acceleration in air (less than ground)
const AIR_FRICTION = 600.0  # Friction in air

# Jump Constants
const JUMP_VELOCITY = -400.0
const JUMP_CUT_MULTIPLIER = 0.5  # How much to reduce upward velocity when releasing jump
const COYOTE_TIME = 0.15  # Grace period to jump after leaving ground
const JUMP_BUFFER_TIME = 0.1  # Remember jump input before landing

# Combat Constants
const KNOCKBACK_VELOCITY = -400.0
const KNOCKBACK_HORIZONTAL = 500.0
const PUSH_FORCE = 1000.0
const KNOCKBACK_TIME = 0.5
const KNOCKBACK_DECELERATION = 1500.0

# Squash & Stretch
const SQUASH_AMOUNT = 0.8  # Landing squash (0.8 = 20% squashed)
const STRETCH_AMOUNT = 1.2  # Jump stretch (1.2 = 20% stretched)
const SQUASH_DURATION = 0.15  # How long squash/stretch lasts

# Dust Particle Settings
const MIN_FALL_FOR_DUST = 20.0  # Minimum fall distance to spawn dust (in pixels)
const DUST_SCALE_MULTIPLIER = 0.01  # How much fall distance affects dust size


# Variables
var last_knockback_time: float = 0.0
var hurt: bool = false
var in_knockback: bool = false
var life: int = 3
var is_active: bool = true
var collected_battery: int = 0
var canJump: bool = true

# Enhanced Movement Variables
var coyote_timer: float = 0.0  # Tracks time since leaving ground
var jump_buffer_timer: float = 0.0  # Tracks jump input before landing
var is_jumping: bool = false  # True when jump button is held
var last_floor_y: float = 0.0  # Track fall distance for landing effects

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
		in_knockback = false

func take_damage(damage_object_position, damage: int = 1) -> void:

	# First Check if we are allow to give damage
	if not is_active or hurt or Time.get_ticks_msec() / 1000.0 < last_knockback_time + KNOCKBACK_TIME:
		return

	# Apply knockback jump
	velocity.y = KNOCKBACK_VELOCITY

	# Check if damage_object_position is valid if yes so apply the knockback based on it
	if damage_object_position != null:
		if damage_object_position.x < global_position.x:
			velocity.x = KNOCKBACK_HORIZONTAL
		else:
			velocity.x = -KNOCKBACK_HORIZONTAL


	# Here we check if player is not already hurt so apply hurt + damage same time we are handling die functions as well

	last_knockback_time = Time.get_ticks_msec() / 1000.0
	in_knockback = true
	if not hurt:
		hurt = true
		life -= damage
		player_ui.update_healthbar(life)
		if life <= 0:
			is_active = false
			animated_sprite.play("die")
			FadeController.fade_in()
			AudioPlayer.stop_all_music()
			AudioPlayer.play_music("game_over")
			# Create a 0.5 second timer and on time out change scene to main menu
			get_tree().create_timer(1.5).connect("timeout", _on_death_timer_timeout)
		else:
			animated_sprite.play("hurt")
			AudioPlayer.play_music("hurt")

func _physics_process(delta: float) -> void:
	var was_on_floor_before = is_on_floor()
	
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.8
		if jump_timer.is_stopped():
			jump_timer.start(0.2)
		# Count coyote time
		coyote_timer += delta
	else:
		canJump = true
		coyote_timer = 0.0
		is_jumping = false
	
	# Decrease jump buffer timer
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Get player input
	var direction := Input.get_axis("left", "right")
	
	# Jump input buffering
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	# Handle jump with coyote time and jump buffering
	if not hurt and jump_buffer_timer > 0 and (is_on_floor() or coyote_timer < COYOTE_TIME) and canJump:
		_perform_jump()
		jump_buffer_timer = 0.0
		coyote_timer = COYOTE_TIME  # Prevent double jump
	
	# Variable jump height - cut jump short if button released
	if is_jumping and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
		is_jumping = false
	
	# Handle horizontal movement with acceleration/deceleration
	if in_knockback:
		# During knockback, smoothly decelerate
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_DECELERATION * delta)
	elif direction and is_active:
		# Apply acceleration (different for ground vs air)
		var accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		if not hurt:
			animated_sprite.flip_h = direction < 0
	else:
		# Apply friction (different for ground vs air)
		var friction = FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
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
	
	# Check if just landed (AFTER move_and_slide)
	if is_on_floor() and not was_on_floor_before:
		_on_landed()
	
	# Update last floor position when on ground
	if is_on_floor():
		last_floor_y = global_position.y
	
	check_tile_damage()

func _perform_jump() -> void:
	"""Execute a jump with visual effects"""
	velocity.y = JUMP_VELOCITY
	is_jumping = true
	animated_sprite.play("jump")
	AudioPlayer.play_music("jump")
	# Squash & stretch effect
	_apply_squash_stretch(Vector2(SQUASH_AMOUNT, STRETCH_AMOUNT))

func _on_landed() -> void:
	"""Called when player lands on ground"""
	# Calculate fall distance for impact effects
	var fall_distance = global_position.y - last_floor_y
	
	print("Fall distance: ", fall_distance)  # Debug
	
	# Only spawn dust if fell from significant height
	if fall_distance > MIN_FALL_FOR_DUST:
		_spawn_dust_particles(fall_distance)
	
	# Only apply squash effect if fell from significant height
	if fall_distance > 50:
		# Squash effect on landing
		_apply_squash_stretch(Vector2(STRETCH_AMOUNT, SQUASH_AMOUNT))

func _apply_squash_stretch(scale_target: Vector2) -> void:
	"""Apply squash and stretch animation to sprite"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Squash/stretch
	tween.tween_property(animated_sprite, "scale", scale_target, SQUASH_DURATION * 0.5)
	# Return to normal
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, SQUASH_DURATION * 0.5)

func _spawn_dust_particles(fall_distance: float = 0.0) -> void:
	"""Spawn dust particles at the bottom of the player when landing"""
	if DUST_PARTICALS == null:
		print("ERROR: DUST_PARTICALS is null!")
		return
	
	var dust = DUST_PARTICALS.instantiate()
	get_parent().add_child(dust)
	
	# Position at the bottom of the player
	dust.global_position = $dust_spawner.global_position
	
	# Scale dust based on fall distance (bigger fall = bigger dust)
	# Min scale: 1.0, Max scale: 2.0
	var dust_scale = clamp(1.0 + (fall_distance * DUST_SCALE_MULTIPLIER), 1.0, 2.5)
	
	# Apply scale to the dust particle's sprite
	if dust.has_node("AnimatedSprite2D"):
		var dust_sprite = dust.get_node("AnimatedSprite2D")
		dust_sprite.scale = Vector2(dust_scale, dust_scale)
	

	print("Dust spawned at fall distance: ", fall_distance, " with scale: ", dust_scale)

func check_tile_damage():
	var local_pos := tileMap.to_local(global_position + Vector2(0, 8))
	var cell := tileMap.local_to_map(local_pos)
	var tile_data := tileMap.get_cell_tile_data(cell)

	if tile_data and tile_data.get_custom_data("damage") == 1:
		take_damage(null, 1)

func update_battery(battery: int = 1) -> void:
	collected_battery += battery
	AudioPlayer.play_music("collect")
	player_ui.update_label(collected_battery)

func _on_death_timer_timeout() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _on_timer_timeout() -> void:
	canJump = false

# This is only for dev mode not in original game
func _input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		GlobalManager.reset_save()
		print("Reset Successful")
