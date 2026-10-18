@tool
extends EditorPlugin



const REPO_ZIP_URL: String = "https://github.com/WirelessNine/Godot-Toolbox/archive/refs/heads/main.zip"
const TEMP_ZIP_PATH: String = "user://temp_toolbox.zip"

var window: AcceptDialog = null


func _enter_tree() -> void:
	add_tool_menu_item("Update Plugins", _open_update_window)


func _exit_tree() -> void:
	remove_tool_menu_item("Update Plugins")

	if is_instance_valid(window):
		window.queue_free()

func start_update(plugin_name: String, replace_name: String) -> void:
	prints("zaza", plugin_name, replace_name)


func download_repository() -> void:
	print("Downloading Toolbox Repository...")

	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.download_file = TEMP_ZIP_PATH

	var error: Error = http.request(REPO_ZIP_URL)
	if not error == OK:
		printerr("Failed to send HTTP request: ", error)
		return

	var result: Array = await http.request_completed
	http.queue_free()

	var response_code: int = result[1]
	if response_code == 200:
		print("Repository downlaoded to: ", TEMP_ZIP_PATH)
	else:
		printerr("Download failed with responde code: ", response_code)




func _open_update_window() -> void:
	if is_instance_valid(window):
		window.popup_centered()
		return

	window = AcceptDialog.new()
	window.title = "Update Plugin"
	
	var v_box := VBoxContainer.new()
	var plugin_edit := LineEdit.new()
	var replace_edit := LineEdit.new()
	
	window.add_child(v_box)
	v_box.add_child(plugin_edit)
	v_box.add_child(replace_edit)
	
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	plugin_edit.placeholder_text = "Plugin Name"
	replace_edit.placeholder_text = "Replace Name"

	EditorInterface.get_base_control().add_child(window)

	window.popup_centered()
	
	window.confirmed.connect(func() -> void:
		start_update(plugin_edit.text, replace_edit.text)
		)
	window.close_requested.connect(window.queue_free)
