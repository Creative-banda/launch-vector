extends Node2D

@export var door_type: String = "locked" # Options: "locked", "unlocked", "open"

@onready var lock_door: Sprite2D = $door_locked
@onready var unlock_door: Sprite2D = $door_unlock
@onready var open_door: Sprite2D = $door_open
@export var switch: Node2D

func _ready() -> void:
	_update_door_visuals()

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
				switch.call_deferred("_switch_state", true)
		"open":
			open_door.visible = true
			if switch:
				switch.call_deferred("_switch_state", true)
