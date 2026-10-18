extends Control

const TWEEN_PRESET: TweenPreset = preload("uid://bwhwafmbjoxqd")
const RELATIVE_PRESET = preload("uid://3w441etipppa")

@onready var menu: Menu = $Menu


func _on_play_pressed() -> void:
	menu.toggle()
