@tool
extends EditorPlugin

const AUDIO_MAIN_SCREEN: PackedScene = preload("uid://43xh2xt44mif")
const LIBRARY_PATH_SETTING: String = "wireless_nine/library_path"

var audio_main_screen: Control


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(LIBRARY_PATH_SETTING):
		
		var property_info: Dictionary = {
			"name": LIBRARY_PATH_SETTING,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_GLOBAL_DIR,
			"hint_string": ""
		}

		ProjectSettings.set_setting(LIBRARY_PATH_SETTING, "")
		ProjectSettings.add_property_info(property_info)
		ProjectSettings.set_initial_value(LIBRARY_PATH_SETTING, "")

	audio_main_screen = AUDIO_MAIN_SCREEN.instantiate()
	audio_main_screen.setup()
	EditorInterface.get_editor_main_screen().add_child(audio_main_screen)
	
	_make_visible(false)


func _exit_tree() -> void:
	if audio_main_screen:
		audio_main_screen.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if not audio_main_screen:
		return

	audio_main_screen.visible = visible


func _get_plugin_name() -> String:
	return "Audio"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon(&"AudioStreamPlayer", &"EditorIcons")
