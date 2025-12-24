extends Node2D

@onready var switch_on: Sprite2D = $switch_on
@onready var switch_off: Sprite2D = $switch_off

@export var is_on: bool = false


func _ready() -> void:
	_switch_state(is_on)

func _switch_state(is_switch_on: bool) -> void:
	if not switch_on or not switch_off:
		return
	switch_on.visible = is_switch_on
	switch_off.visible = not is_switch_on
