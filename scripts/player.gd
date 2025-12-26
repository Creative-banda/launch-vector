extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var tileMap: TileMapLayer
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK_VELOCITY = -400.0
const KNOCKBACK_TIME = 0.5
var last_knockback_time: float = 0.0

var hurt: bool = false
var life: int = 3
var is_active: bool = true
var collected_battery: int = 0

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)

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
		if life <= 0:
			is_active = false
			animated_sprite.play("die")
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
	
	move_and_slide()
	check_tile_damage()

func check_tile_damage():
	var local_pos := tileMap.to_local(global_position + Vector2(0, 8))
	var cell := tileMap.local_to_map(local_pos)
	var tile_data := tileMap.get_cell_tile_data(cell)

	if tile_data and tile_data.get_custom_data("damage") == 1:
		take_damage(1)
