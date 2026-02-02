extends Node2D

const SAVE_PATH := "user://save_data.json"

var collected_battery: int = 0
var life: int = 3
var current_level: int = 1
var data := {
	"levels": {
		"level_1": true,
		"level_2": true,
		"level_3": true,
		"level_4": false,
		"level_5": false
	}
}

func _ready():
	load_game()

func save_game():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save game")
		return

	file.store_string(JSON.stringify(data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		save_game() # create default save
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to load game")
		return

	var content := file.get_as_text()
	file.close()

	var result: Variant = JSON.parse_string(content)
	if typeof(result) == TYPE_DICTIONARY:
		data = result
	else:
		push_error("Corrupted save file")

func reset_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	data = {
		"levels": {
			"level_1": true,
			"level_2": false,
			"level_3": false,
			"level_4": false,
			"level_5": false
		}
	}
	save_game()
