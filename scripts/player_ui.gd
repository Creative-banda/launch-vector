extends CanvasLayer

@onready var heart1: Sprite2D = $Control/Sprite2D
@onready var heart2: Sprite2D = $Control/Sprite2D2
@onready var heart3: Sprite2D = $Control/Sprite2D3
@onready var battery_label: Label = $Control/Label

func update_healthbar(health: int) -> void:
	if heart1: heart1.visible = health >= 1
	if heart2: heart2.visible = health >= 2
	if heart3: heart3.visible = health >= 3

func update_label(battery: int) -> void:
	if battery_label:
		battery_label.text = "Battery: " + str(battery)
