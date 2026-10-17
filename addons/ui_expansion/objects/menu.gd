@icon("uid://lxuugoybnvfh")
class_name Menu
extends PanelContainer

##Emitted when the menu is opened.
signal opened
##Emitted when the menu is closed.
signal closed

@export_group("Animation", "animation_")
##The [GDScript] object containing static functions for playing animations.
@export var animation_pack: GDScript
##The static method from [member animation_pack] to play animation for the menu.
@export var animation_method: int
##If [code]true[/code], the state can be overriden while the animation is playing.
@export var animation_can_override: bool = true

@export_group("")
##If [code]true[/code], the menu is added to the Menu stack.
@export var add_to_stack: bool = true
##If [code]true[/code], the background is moved to behind the menu when opened,
##if a background is defined.
@export var move_background: bool = false
##If [code]true[/code], the menu is starts closed.
@export var start_closed: bool = false

var state: bool = false


func _ready() -> void:
	_internal_ready()


##Returns [code]true[/code] if the menu is open.
func is_open() -> bool:
	return state


##Opens the menu.
func open() -> void:
	if not _can_play() or state == true:
		return

	state = true

	#UIAnimation.play_animation(animation_type, self, false)
	if add_to_stack:
		MenuManager.add_to_stack(self)

	opened.emit()
	_opened()


##Closes the menu.
func close() -> void:
	if not _can_play() or state == false:
		return

	state = false

	#UIAnimation.play_animation(animation_type, self, true)
	if add_to_stack:
		MenuManager.remove_from_stack(self)

	closed.emit()
	_closed()


##Flips the menu between closed and open state.
func toggle() -> void:
	if state:
		close()
	else:
		open()


func _internal_ready() -> void:
	visible = not start_closed
	state = not start_closed

	tree_entered.connect(_internal_enter_tree)
	tree_exited.connect(_internal_exit_tree)


func _internal_enter_tree() -> void:
	MenuManager.add_menu(self)


func _internal_exit_tree() -> void:
	MenuManager.remove_menu(self)


func _can_play() -> bool:
	if not animation_can_override:
		return false
	return true


##Called when the menu is opened.
func _opened() -> void:
	pass


##Called when the menu is closed.
func _closed() -> void:
	pass


func _is_playing() -> bool:
	if not animation_pack == null:
		return false
	return false
