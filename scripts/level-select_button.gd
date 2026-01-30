extends Button

@export var isLocked: bool
@export var level : PackedScene

const LEVEL_LOCK = preload("res://assets/UI/level_selector/level_lock.png")
const LEVEL_BUTTON = preload("res://assets/UI/level_selector/level_button.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if isLocked:
		icon = LEVEL_LOCK
		$Label.text = ""
	else:
		icon = LEVEL_BUTTON


func _on_button_down() -> void:
	print("Button pressed")
	if isLocked:
		return
	get_tree().change_scene_to_packed(level)
