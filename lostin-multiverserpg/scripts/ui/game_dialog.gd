class_name GameDialog
extends Control
## Modal dialog with choices. Usage:  var i: int = await dialog.ask("Title", "Text", ["A", "B"], icon)

signal chosen(index: int)

var box: PanelContainer
var title_lbl: Label
var icon_rect: TextureRect
var body: RichTextLabel
var choices_box: VBoxContainer
var _buttons: Array = []
var _open := false
var _cancel := -1


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	add_child(UI.dim_bg())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	box = UI.panel()
	box.custom_minimum_size = Vector2(320, 0)
	center.add_child(box)
	var v := UI.vbox(5)
	box.add_child(v)
	var head := UI.hbox(6)
	v.add_child(head)
	icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(32, 32)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	head.add_child(icon_rect)
	title_lbl = UI.label("", Color(), "TitleLabel")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(title_lbl)
	v.add_child(HSeparator.new())
	body = UI.rich()
	body.custom_minimum_size = Vector2(300, 0)
	v.add_child(body)
	choices_box = UI.vbox(3)
	v.add_child(choices_box)


func ask(title: String, text: String, choices: Array, icon: Texture2D = null, variation: String = "", cancel_index: int = -1) -> int:
	_open = true
	_cancel = cancel_index
	box.theme_type_variation = variation
	title_lbl.text = title
	icon_rect.texture = icon
	icon_rect.visible = icon != null
	if icon:
		# integer upscale only (pixel-perfect): 12px -> 24, 16px -> 32, 32px -> 32, 48px -> 48
		var sz := icon.get_size()
		var k := maxi(1, int(32.0 / maxf(sz.x, sz.y)))
		icon_rect.custom_minimum_size = sz * k
		icon_rect.stretch_mode = TextureRect.STRETCH_SCALE
	body.text = text
	UI.clear(choices_box)
	_buttons.clear()
	for i in choices.size():
		var c = choices[i]
		var txt: String = c if typeof(c) == TYPE_STRING else c["text"]
		var b := UI.button("%d. %s" % [i + 1, txt], func(): _pick(i))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if typeof(c) == TYPE_DICTIONARY:
			b.disabled = c.get("disabled", false)
			if c.has("tip"):
				b.tooltip_text = c["tip"]
		choices_box.add_child(b)
		_buttons.append(b)
	visible = true
	modulate.a = 0.0
	box.scale = Vector2(0.96, 0.96)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.12)
	tw.tween_property(box, "scale", Vector2.ONE, 0.12)
	await get_tree().process_frame
	box.pivot_offset = box.size / 2
	for b in _buttons:
		if not b.disabled:
			b.grab_focus()
			break
	var idx: int = await chosen
	return idx


func _pick(i: int) -> void:
	if not _open:
		return
	_open = false
	visible = false
	chosen.emit(i)


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not _open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var k: int = event.keycode
		if k == KEY_ESCAPE and _cancel >= 0:
			get_viewport().set_input_as_handled()
			_pick(_cancel)
			return
		if k >= KEY_1 and k <= KEY_9:
			var i := k - KEY_1
			if i < _buttons.size() and not _buttons[i].disabled:
				_buttons[i].emit_signal("pressed")
				get_viewport().set_input_as_handled()


## Simple info popup with a single OK button.
func info(title: String, text: String, icon: Texture2D = null, ok: String = "") -> void:
	await ask(title, text, [ok if ok != "" else Loc.t("Continue")], icon)
