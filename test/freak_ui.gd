extends Control

const TWEEN_PRESET: TweenPreset = preload("uid://bwhwafmbjoxqd")
const RELATIVE_PRESET = preload("uid://3w441etipppa")
@onready var bg: ColorRect = $BG

@onready var menu: Menu = $Menu
@onready var menu_2: Menu = $Menu2
@onready var hud: Menu = $HUD


func _ready() -> void:
	MenuManager.set_hud(hud)
	MenuManager.set_background(bg)


func _on_play_pressed() -> void:
	menu.toggle()


func _on_play_2_pressed() -> void:
	menu_2.toggle()
