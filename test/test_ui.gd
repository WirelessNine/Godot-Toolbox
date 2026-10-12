extends Control

@onready var menu: Menu = $Menu
@onready var background: ColorRect = $Background


func _ready() -> void:
	MenuManager.set_background(background)


func _on_toggle_pressed() -> void:
	menu.toggle()


func _on_exit_tree_pressed() -> void:
	menu.queue_free()
