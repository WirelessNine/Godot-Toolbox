extends Node

##If [code]true[/code], the background will move above the menu.
var change_background_order: bool

var _active_menus: Dictionary[String, Menu]
var _stack: Array[Menu]

var _background: Control
var _bg_parent: Node
var _bg_preset: TweenPreset

var _is_bg_visible: bool = false


func _unhandled_key_input(event: InputEvent) -> void:
	if _stack.is_empty():
		return

	if not (event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE):
		return

	var menu: Menu = _stack.back()
	menu.close()


##Adds a new [Menu].
func add_menu(menu: Menu) -> void:
	_active_menus[menu.name.to_snake_case()] = menu


##Removes a [Menu].
func remove_menu(menu: Menu) -> void:
	_active_menus.erase(menu.name.to_snake_case())

	remove_from_stack(menu)


##Opens the [Menu] whose [param menu_name] matches.
func open_menu(menu_name: String) -> void:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	_active_menus[menu_name].open()


##Closes the [Menu] whose [param menu_name] matches.
func close_menu(menu_name: String) -> void:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	_active_menus[menu_name].close()


##Returns the [Menu] whose [param menu_name] matches.
func get_menu(menu_name: String) -> Menu:
	if not menu_name in _active_menus:
		push_error(menu_name, " does not exist!")
		return

	return _active_menus[menu_name]


##Adds [param menu] to the stack.
func add_to_stack(menu: Menu) -> void:
	_stack.append(menu)

	move_background(menu)


##Removes [param menu] to the stack.
##If [param erase_only], the menu is only removed from the stack.
func remove_from_stack(menu: Menu) -> void:
	var menu_index: int = _stack.find(menu)
	var last_index: int = _stack.size() - 1

	_stack.erase(menu)

	if not menu_index == last_index:
		return

	move_background(_stack.back() if not _stack.is_empty() else null)


##Returns [code]true[/code] if the menu stack is empty.
func is_stack_empty() -> bool:
	return _stack.is_empty()


##Sets background to [param new_background].
func set_background(new_background: Control) -> void:
	_background = new_background
	_bg_parent = new_background.get_parent()

	_bg_parent.move_child(_background, 0)

	new_background.hide()


##Sets background tween preset to [param preset].
func set_background_preset(new_preset: TweenPreset) -> void:
	_bg_preset = new_preset


##Moves the background behind [param menu].
##If no backgrond is defined, nothing happens.
func move_background(menu: Menu) -> void:
	if _background == null:
		return

	if menu == null or not menu.move_background:
		_toggle_background(false)
		return

	var menu_parent: Node = menu.get_parent()

	if not _bg_parent == menu_parent:
		_background.reparent(menu_parent)

	var menu_index: int = menu.get_index()

	if _background.get_index() < menu_index:
		menu_index -= 1

	#menu_parent.move_child(_background, 0)
	menu_parent.move_child(_background, menu_index)

	_toggle_background(true)


func _toggle_background(visible: bool) -> void:
	if visible == _is_bg_visible:
		return

	if _bg_preset == null:
		_background.visible = visible
	else:
		_bg_preset.play(_background, not visible)

	_is_bg_visible = visible
