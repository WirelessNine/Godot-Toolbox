@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"Menu",
		"PanelContainer",
		preload("uid://rxwty6cd03ab"),
		preload("uid://lxuugoybnvfh"),
	)


func _exit_tree() -> void:
	remove_custom_type("Menu")


func _enable_plugin() -> void:
	add_autoload_singleton("MenuManager", "res://addons/ui_expansion/singletons/menu_manager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton("MenuManager")
