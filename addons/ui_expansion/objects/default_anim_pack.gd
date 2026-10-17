@abstract
extends Object
##Singleton for reusable animations for UI.

const META_NAME: StringName = &"tween"


static func play_none(node: Control, reverse: bool) -> void:
	if reverse:
		node.hide()
	else:
		node.show()


static func play_fall(node: Control, reverse: bool) -> void:
	var tween: Tween = _create_tween(node).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)
	node.offset_transform_enabled = true
	
	node.modulate.a = 0.0 if not reverse else 1.0
	node.offset_transform_scale = Vector2(1.1, 1.1) if not reverse else Vector2(1.0, 1.0)

	var target_alpha: float = 1.0 if not reverse else 0.0
	var target_scale: Vector2 = Vector2(1.0, 1.0) if not reverse else Vector2(1.1, 1.1)

	tween.tween_property(node, ^"modulate:a", target_alpha, 0.2)
	tween.tween_property(node, ^"offset_transform_scale", target_scale, 0.2)

	if reverse:
		tween.chain().tween_callback(node.hide)
	else:
		node.show()


static func play_slide(node: Control, reverse: bool) -> void:
	var tween: Tween = _create_tween(node).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)
	node.offset_transform_enabled = true

	node.modulate.a = 0.0 if not reverse else 1.0
	node.offset_transform_position_ratio.x = -0.1 if not reverse else 0.0

	var target_alpha: float = 1.0 if not reverse else 0.0
	var target_ratio: float = 0.0 if not reverse else -0.1

	tween.tween_property(node, ^"modulate:a", target_alpha, 0.2)
	tween.tween_property(node, ^"offset_transform_position_ratio:x", target_ratio, 0.35)

	if reverse:
		tween.chain().tween_callback(node.hide)
	else:
		node.show()


static func play_fade_down(node: Control, reverse: bool) -> void:
	var tween: Tween = _create_tween(node).set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(
		Tween.EASE_OUT
	)

	node.offset_transform_enabled = true
	node.offset_transform_position_ratio.y = 0.1 if not reverse else 0.0

	var target_ratio: float = 0.0 if not reverse else 0.1

	tween.tween_property(node, ^"offset_transform_position_ratio:y", target_ratio, 0.2)

	if reverse:
		tween.chain().tween_callback(node.hide)
	else:
		node.show()


static func node_is_playing(node: Control) -> bool:
	var tween: Tween = node_get_tween(node)

	return is_instance_valid(tween) and tween.is_running()


static func node_get_tween(node: Control) -> Tween:
	if not node.has_meta(META_NAME):
		return null

	return node.get_meta(META_NAME)


static func node_set_tween(node: Control, tween: Tween) -> void:
	node.set_meta(META_NAME, tween)


static func node_has_tween(node: Control) -> bool:
	return node.has_meta(META_NAME)


static func _create_tween(node: Control) -> Tween:
	var tween: Tween = node.create_tween()

	if node_is_playing(node):
		node_get_tween(node).kill()

	node_set_tween(node, tween)

	return tween
