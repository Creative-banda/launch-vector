extends Node2D

# Export variables
@export_enum("locked", "unlocked", "open") var door_type: String = "locked"
@onready var lock_door: Sprite2D = $door_locked
@export var switch: Node2D
@export var is_exit_door: bool = false
@export var next_level: PackedScene # If set, goes to next level; if null, goes to main menu

# Instances
@onready var unlock_door: Sprite2D = $door_unlock
@onready var open_door: Sprite2D = $door_open
@onready var label: Label = $Label
@export var battery_required: int = 3

func _ready() -> void:
	_update_door_visuals()
	if door_type == "locked":
		label.text = str(battery_required)
	else:
		label.text = ""

func _update_door_visuals() -> void:
	lock_door.visible = false
	unlock_door.visible = false
	open_door.visible = false
	match door_type:
		"locked":
			# Update visuals for locked door
			lock_door.visible = true
			if switch:
				switch.call_deferred("_switch_state", false)
		"unlocked":
			# Update visuals for unlocked door
			unlock_door.visible = true
			if switch:
				switch.call_deferred("_switch_state", false)
		"open":
			open_door.visible = true
			if switch:
				switch.call_deferred("_switch_state", true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "player":
		print("Player entered the door")
		if door_type == "locked" or door_type == "unlocked":
			if body.collected_battery > 0 and battery_required > 0:
				_consume_battery(body)
			else:
				print("Player doesn't have enough batteries")

func _consume_battery(player: Node2D) -> void:
	# Check if we should continue consuming batteries
	if player.collected_battery > 0 and battery_required > 0:
		# Consume one battery from player
		battery_required -= 1
		player.update_battery(-1)
		
		# Update the label to show remaining required batteries
		label.text = str(battery_required)
		
		# Check door state after consumption
		if battery_required == 1:
			# Door becomes unlocked when only 1 battery is required
			door_type = "unlocked"
			_update_door_visuals()
		elif battery_required == 0:
			# Door becomes open when no batteries are required
			door_type = "open"
			_update_door_visuals()
			label.text = ""
		if door_type == "open" and is_exit_door:
			GlobalManager.current_level += 1
			FadeController.fade_in()
			await get_tree().create_timer(0.5).timeout
			
			# If next_level is set, go to that level; otherwise go to main menu
			if next_level:
				get_tree().change_scene_to_packed(next_level)
				unlock_next_level(GlobalManager.current_level)
			else:
				get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
			return # Stop recursion

		# Call this function again after 0.5 seconds
		await get_tree().create_timer(0.5).timeout
		_consume_battery(player)


func unlock_next_level(current_level: int):
	var nextLevel := "level_%d" % (current_level)

	if GlobalManager.data["levels"].has(nextLevel):
		GlobalManager.data["levels"][nextLevel] = true
		GlobalManager.save_game()
