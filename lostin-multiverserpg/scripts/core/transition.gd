extends CanvasLayer
## Fade transitions between scenes. Autoload name: Transition

var rect: ColorRect
var busy := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	rect = ColorRect.new()
	rect.color = Color("#05030a")
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate.a = 0.0
	add_child(rect)


func change_scene(path: String, dur: float = 0.3) -> void:
	if busy:
		return
	busy = true
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw := create_tween()
	tw.tween_property(rect, "modulate:a", 1.0, dur)
	await tw.finished
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(rect, "modulate:a", 0.0, dur)
	await tw2.finished
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	busy = false


func flash(col: Color, dur: float = 0.25) -> void:
	rect.color = col
	rect.modulate.a = 0.8
	var tw := create_tween()
	tw.tween_property(rect, "modulate:a", 0.0, dur)
	await tw.finished
	rect.color = Color("#05030a")
