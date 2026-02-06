extends Button

@export var level : PackedScene
var isLocked: bool = true

const LEVEL_LOCK = preload("res://assets/UI/level_selector/level_lock.png")
const LEVEL_BUTTON = preload("res://assets/UI/level_selector/level_button.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if GlobalManager.data["levels"].has(self.name):
		isLocked = not GlobalManager.data["levels"][self.name]
	
	if isLocked:
		icon = LEVEL_LOCK
		$Label.text = ""
	else:
		icon = LEVEL_BUTTON

func _on_button_down() -> void:
	print("Button pressed")
	AudioPlayer.stop_all_music()
	if isLocked:
		return
	# get_tree().change_scene_to_packed(level)
	FadeController.fade_in(level)
