extends Node

var _active_menus: Dictionary[String, Menu]
var _stack: Array[Menu]

var _hud: Menu

var _background: Control
var _background_parent: Node
var _background_preset: TweenPreset

var _is_background_visible: bool = false


func _unhandled_key_input(event: InputEvent) -> void:
	if _stack.is_empty():
		return

	if not (event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE):
		return

	var menu: Menu = _stack.back()
	menu.close()


##Registers the [param menu].
func register_menu(menu: Menu) -> void:
	var converted_name: String = _convert_name(menu.name)

	_active_menus[converted_name] = menu


##Unregisters the [param menu].
func unregister_menu(menu: Menu) -> void:
	var converted_name: String = _convert_name(menu.name)

	_active_menus.erase(converted_name)
	remove_from_stack(menu)


##Adds [param menu] to the stack.
func add_to_stack(menu: Menu) -> void:
	_stack.append(menu)

	move_background(menu)
	toggle_hud(menu)


##Removes [param menu] to the stack.
func remove_from_stack(menu: Menu) -> void:
	var menu_index: int = _stack.find(menu)
	var last_index: int = _stack.size() - 1

	_stack.erase(menu)

	if not menu_index == last_index:
		return

	var current_menu: Menu = _stack.back() if not _stack.is_empty() else null

	move_background(current_menu)
	toggle_hud(current_menu)


##Opens the [Menu] whose [param menu_name] matches.
func open_menu(menu_name: String) -> void:
	var menu: Menu = get_menu(menu_name)

	if not menu == null:
		menu.open()


##Closes the [Menu] whose [param menu_name] matches.
func close_menu(menu_name: String) -> void:
	var menu: Menu = get_menu(menu_name)

	if not menu == null:
		menu.close()


##Returns the [Menu] whose [param menu_name] matches.
func get_menu(menu_name: String) -> Menu:
	var converted_name: String = _convert_name(menu_name)

	var menu: Menu = _active_menus.get(converted_name)

	if menu == null:
		push_error(converted_name, " does not exist!")

	return menu


##Returns [code]true[/code] if [param menu_name] is active.
func has_menu(menu_name: String) -> bool:
	var converted_name: String = _convert_name(menu_name)

	return converted_name in _active_menus


##Returns [code]true[/code] if the menu stack is empty.
func is_stack_empty() -> bool:
	return _stack.is_empty()


##Sets the hud to [param new_hud].
func set_hud(new_hud: Menu) -> void:
	_hud = new_hud

	new_hud.add_to_stack = false
	new_hud.move_background = false

	if is_stack_empty():
		new_hud.open()


##Sets background to [param new_background].
func set_background(new_background: Control) -> void:
	_background = new_background
	_background_parent = new_background.get_parent()

	_background_parent.move_child(_background, 0)

	new_background.hide()


##Sets background tween preset to [param preset].
func set_background_preset(new_preset: TweenPreset) -> void:
	_background_preset = new_preset


##Toggles the HUD based on [param menu].
##If no HUD is assigned, nothing happens.
func toggle_hud(menu: Menu) -> void:
	if _hud == null:
		return

	if menu == null or not menu.close_hud:
		_hud.open()
		return

	_hud.close()


##Moves the background behind [param menu].
##If no background is assigned, nothing happens.
func move_background(menu: Menu) -> void:
	if _background == null:
		return

	if menu == null or not menu.move_background:
		_toggle_background(false)
		return

	var menu_parent: Node = menu.get_parent()

	if not _background_parent == menu_parent:
		_background.reparent(menu_parent)

	var menu_index: int = menu.get_index()

	if _background.get_index() < menu_index:
		menu_index -= 1

	#menu_parent.move_child(_background, 0)
	menu_parent.move_child(_background, menu_index)

	_toggle_background(true)


func _toggle_background(visible: bool) -> void:
	if visible == _is_background_visible:
		return

	if _background_preset == null:
		_background.visible = visible
	else:
		_background_preset.play(_background, not visible)

	_is_background_visible = visible


##Converts [param menu_name] into snake_case.
func _convert_name(menu_name: String) -> String:
	return menu_name.to_snake_case()
