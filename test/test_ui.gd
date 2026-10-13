extends Control

const SLOT: PackedScene = preload("uid://cpeesqbdlitxj")
@onready var grid: GridContainer = $Grid
@onready var requested: HBoxContainer = $Requested

var array: Array[int] = [64, 23, 87, 4, 1, 39, 5, 10, 23, 55]

var pool: ScenePool


func _ready() -> void:
	pool = ScenePool.new(ScenePool.AccessMode.DYNAMIC, SLOT, grid, 8, 5, _custom_action)


func update_slot(slot: Label, value: int) -> void:
	slot.update(value)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_0 and event.is_pressed():
			var time: float = Time.get_ticks_usec()
			var scene: Label = pool.request_scene()

			if scene:
				scene.update(array.pick_random())

			prints("Request time:", Time.get_ticks_usec() - time)

			await get_tree().create_timer(5.0).timeout

			time = Time.get_ticks_usec()
			pool.return_scene(scene)
			prints("Return time:", Time.get_ticks_usec() - time)


func _custom_action(mode: ScenePool.ActionMode, scene: Node) -> void:
	match mode:
		ScenePool.ActionMode.CREATED:
			if scene is CanvasItem:
				scene.hide()

		ScenePool.ActionMode.RETURNED:
			if scene is CanvasItem:
				scene.hide()

		ScenePool.ActionMode.REQUESTED:
			if scene is CanvasItem:
				scene.show()
