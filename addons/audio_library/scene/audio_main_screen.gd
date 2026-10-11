@tool
extends MarginContainer

enum Column {
	NAME = 0,
	EXTENSION = 1,
	ADD = 2,
	ACTION = 3,
}

enum Type {
	DIRECTORY,
	FILE,
}

const LIBRARY_PATH_SETTING: String = "wireless_nine/library_path"

const ADD_ICON = preload("uid://d1mrcuem5delc")
const AUDIO_ICON = preload("uid://bucxxc42ahk6f")
const FOLDER_ICON = preload("uid://b5pgn2f1uxvgo")
const OPEN_ICON = preload("uid://i6ro7lcdqkhv")
const PLAY_ICON = preload("uid://v65d3ax1dpqc")
const STOP_ICON = preload("uid://cpwva5vpxr3qj")

var playing_item: TreeItem

var streams: Dictionary[String, AudioStream]

var dir_access: DirAccess
var dir_access_path: String

var library_path: String

var found_dirs: PackedStringArray
var found_files: PackedStringArray

@onready var search_bar: LineEdit = %Search
@onready var open_folder_button: Button = %OpenFolder
@onready var back_button: Button = %Back
@onready var reload_button: Button = %Reload
@onready var items_tree: Tree = %Items
@onready var audio_player: AudioStreamPlayer = %AudioPlayer


func setup() -> void:
	if not is_node_ready():
		await ready

	search_bar.text_submitted.connect(_on_search_bar_text_submitted)
	open_folder_button.pressed.connect(open_audio_dir)
	back_button.pressed.connect(back)
	reload_button.pressed.connect(refresh)
	items_tree.gui_input.connect(_on_items_tree_gui_input)
	audio_player.finished.connect(_on_audio_player_finished)

	_tree_setup()


func refresh() -> void:
	library_path = ProjectSettings.get_setting(LIBRARY_PATH_SETTING, "")
	streams.clear()

	if not library_path:
		items_tree.clear()
		return

	dir_access = DirAccess.open(library_path)
	dir_access_path = library_path

	open_dir(library_path)


func back() -> void:
	if dir_access_path == library_path:
		return

	open_dir(dir_access_path.get_base_dir())


func open_audio_dir() -> void:
	if not library_path:
		return

	OS.shell_open(library_path)


func open_dir(path: String) -> void:
	dir_access = DirAccess.open(path)
	dir_access_path = path

	var access_dirs: PackedStringArray = dir_access.get_directories()
	var access_files: PackedStringArray = dir_access.get_files()

	var dirs: PackedStringArray
	var files: PackedStringArray

	dirs.resize(access_dirs.size())
	files.resize(access_files.size())

	for x: int in access_dirs.size():
		var string: String = access_dirs[x]
		dirs[x] = "%s/%s" % [path, string]

	for x: int in access_files.size():
		var string: String = access_files[x]
		files[x] = "%s/%s" % [path, string]

	tree_populate(dirs, files)


func copy_stream(path: String) -> void:
	var res: String = ProjectSettings.globalize_path("res://")

	var copy_path: String = "%s%s" % [res, path.get_file()]
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var copy: FileAccess = FileAccess.open(copy_path, FileAccess.WRITE)

	if copy:
		copy.store_buffer(bytes)
		copy.close()

		EditorInterface.get_resource_filesystem().scan()
	else:
		push_error("Failed to copy file at ", copy_path)


func play_stream(path: String, item: TreeItem) -> void:
	if is_instance_valid(playing_item):
		playing_item.set_icon(Column.ACTION, PLAY_ICON)

	if playing_item == item:
		audio_player.stop()
		item.set_icon(Column.ACTION, PLAY_ICON)
		playing_item = null
		return

	if not path in streams:
		load_stream(path)

	playing_item = item
	audio_player.stream = streams[path]
	audio_player.play()

	item.set_icon(Column.ACTION, STOP_ICON)


func load_stream(path: String) -> void:
	if path in streams:
		return

	var extension: String = path.get_extension()
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	var stream: AudioStream

	match extension:
		"mp3":
			stream = AudioStreamMP3.load_from_buffer(bytes)
		"wav":
			stream = AudioStreamWAV.load_from_buffer(bytes)
		"ogg":
			stream = AudioStreamOggVorbis.load_from_buffer(bytes)

	streams[path] = stream


func search(from_path: String, pattern: String) -> void:
	var search_access: DirAccess = DirAccess.open(from_path)

	for x: String in search_access.get_directories():
		var path: String = "%s/%s" % [from_path, x]

		if pattern.to_lower() in x.to_lower():
			found_dirs.append(path)

		search(path, pattern)

	for x: String in search_access.get_files():
		if pattern.to_lower() in x.to_lower():
			var path: String = "%s/%s" % [from_path, x]
			found_files.append(path)


func tree_reset() -> void:
	items_tree.clear()
	items_tree.create_item()


func tree_populate(dirs: PackedStringArray, files: PackedStringArray) -> void:
	tree_reset.call_deferred()

	tree_populate_dirs.call_deferred(dirs)
	tree_populate_files.call_deferred(files)


func tree_populate_dirs(dirs: PackedStringArray) -> void:
	for x: String in dirs:
		_tree_create_dir_item(x)


func tree_populate_files(files: PackedStringArray) -> void:
	for x: String in files:
		_tree_create_file_item(x)


func _tree_create_dir_item(path: String) -> void:
	var item: TreeItem = items_tree.create_item()
	var directory_name: String = path.get_basename().get_file()

	item.set_meta(&"path", path)
	item.set_meta(&"type", Type.DIRECTORY)

	item.set_icon(Column.NAME, FOLDER_ICON)
	item.set_text(Column.NAME, directory_name)

	item.set_cell_mode(Column.ACTION, TreeItem.CELL_MODE_ICON)
	item.set_icon(Column.ACTION, OPEN_ICON)


func _tree_create_file_item(path: String) -> void:
	var item: TreeItem = items_tree.create_item()
	var audio_name: String = path.get_basename().get_file()
	var audio_extension: String = path.get_extension()

	item.set_meta(&"path", path)
	item.set_meta(&"type", Type.FILE)

	item.set_icon(Column.NAME, AUDIO_ICON)
	item.set_text(Column.NAME, audio_name)

	item.set_text(Column.EXTENSION, audio_extension)
	item.set_text_alignment(Column.EXTENSION, HORIZONTAL_ALIGNMENT_CENTER)

	item.set_cell_mode(Column.ADD, TreeItem.CELL_MODE_ICON)
	item.set_icon(Column.ADD, ADD_ICON)

	item.set_cell_mode(Column.ACTION, TreeItem.CELL_MODE_ICON)
	item.set_icon(Column.ACTION, PLAY_ICON)


func _tree_setup() -> void:
	items_tree.columns = Column.size()
	items_tree.hide_folding = true
	items_tree.hide_root = true
	items_tree.select_mode = Tree.SELECT_ROW

	items_tree.set_column_expand(Column.NAME, true)

	items_tree.set_column_expand(Column.EXTENSION, false)
	items_tree.set_column_custom_minimum_width(Column.EXTENSION, 100)

	items_tree.set_column_expand(Column.ADD, false)
	items_tree.set_column_custom_minimum_width(Column.ADD, 50)

	items_tree.set_column_expand(Column.ACTION, false)
	items_tree.set_column_custom_minimum_width(Column.ACTION, 50)


func _on_items_tree_gui_input(event: InputEvent) -> void:
	if not (
		event is InputEventMouseButton and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		return

	var item: TreeItem = items_tree.get_item_at_position(event.position)

	if not item:
		return

	var column: int = items_tree.get_column_at_position(event.position)

	var path: String = item.get_meta(&"path")
	var type: Type = item.get_meta(&"type")
	
	match type:
		Type.DIRECTORY:
			open_dir(path)
		Type.FILE:
			if column == Column.ADD:
				copy_stream(path)
			elif column == Column.ACTION or column == 0:
				play_stream(path, item)


func _on_audio_player_finished() -> void:
	if is_instance_valid(playing_item):
		playing_item.set_icon(Column.ACTION, PLAY_ICON)
		playing_item = null


func _on_search_bar_text_submitted(new_text: String) -> void:
	if not library_path:
		return

	if not new_text:
		open_dir(library_path)

	found_dirs.clear()
	found_files.clear()

	search(library_path, new_text)

	tree_populate(found_dirs, found_files)
