class_name UI
extends RefCounted
## Small helpers to build pixel UI in code.

const BAR_HP := Color("#c8323a")
const BAR_HP_HI := Color("#ff6a5a")
const BAR_MIND := Color("#6a5ad8")
const BAR_MIND_HI := Color("#a89aff")
const BAR_HUNGER := Color("#d8861e")
const BAR_EXP := Color("#e8c42a")


static func label(text: String, color: Color = Color(0, 0, 0, 0), variation: String = "") -> Label:
	var l := Label.new()
	l.text = text
	if variation != "":
		l.theme_type_variation = variation
	# Color() is opaque black in Godot 4 -> treat it as "use theme colour"
	if color.a > 0 and color != Color(0, 0, 0, 1):
		l.add_theme_color_override("font_color", color)
	return l


static func rich(text: String = "", fit: bool = true, min_w: int = 0) -> RichTextLabel:
	var r := RichTextLabel.new()
	if min_w > 0:
		r.custom_minimum_size = Vector2(min_w, 0)
	r.bbcode_enabled = true
	r.fit_content = fit
	r.scroll_active = not fit
	r.text = text
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.mouse_filter = Control.MOUSE_FILTER_PASS
	return r


static func button(text: String, cb: Callable = Callable(), icon: Texture2D = null, variation: String = "") -> Button:
	var b := Button.new()
	b.text = text
	if icon:
		b.icon = icon
	if variation != "":
		b.theme_type_variation = variation
	b.focus_mode = Control.FOCUS_ALL
	if cb.is_valid():
		b.pressed.connect(cb)
	b.mouse_entered.connect(func(): if not b.disabled: Sfx.play("move", 0.05, -6))
	b.pressed.connect(func(): Sfx.play("select", 0.03, -4))
	return b


static func icon_rect(tex: Texture2D, scale_: int = 1) -> TextureRect:
	var t := TextureRect.new()
	t.texture = tex
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	if tex:
		t.custom_minimum_size = tex.get_size() * scale_
		if scale_ > 1:
			t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			t.stretch_mode = TextureRect.STRETCH_SCALE
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.mouse_filter = Control.MOUSE_FILTER_PASS
	return t


static func bar(fill: Color, w: int = 80, h: int = 6) -> ProgressBar:
	var p := ProgressBar.new()
	p.show_percentage = false
	p.custom_minimum_size = Vector2(w, h)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("#0c0910")
	bg.border_color = Color("#07050b")
	bg.set_border_width_all(1)
	bg.anti_aliasing = false
	var f := StyleBoxFlat.new()
	f.bg_color = fill
	f.border_color = fill.lightened(0.3)
	f.border_width_top = 1
	f.anti_aliasing = false
	p.add_theme_stylebox_override("background", bg)
	p.add_theme_stylebox_override("fill", f)
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	return p


static func hbox(sep: int = 4) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h


static func vbox(sep: int = 2) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v


static func panel(variation: String = "") -> PanelContainer:
	var p := PanelContainer.new()
	if variation != "":
		p.theme_type_variation = variation
	return p


static func margin(m: int) -> MarginContainer:
	var c := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		c.add_theme_constant_override("margin_" + side, m)
	return c


static func spacer(w: int = 0, h: int = 0, expand: bool = false) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	if expand:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func dim_bg() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(0.02, 0.01, 0.04, 0.72)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_STOP
	return r


static func status_row(statuses: Dictionary, with_tooltip: bool = true) -> HBoxContainer:
	var h := hbox(1)
	for id in statuses:
		var tex := DB.status_icon(id)
		if tex == null:
			continue
		var r := icon_rect(tex)
		var st: Dictionary = statuses[id]
		if with_tooltip:
			r.tooltip_text = "%s\n%s" % [DB.status_name(id, int(st.get("stacks", 1))), DB.status_desc(id)]
		h.add_child(r)
	return h


static func item_tooltip(id: String) -> String:
	var it := DB.item(id)
	if it.is_empty():
		return id
	var s := "%s  [%s]\n%s" % [DB.item_name(id), DB.kind_label(it["kind"]), DB.item_desc(id)]
	match it["kind"]:
		"weapon":
			s += "\nATK +%d  %s %d%%" % [int(it.get("atk", 0)), Loc.t("Accuracy"), int(it.get("acc", 90))]
			if int(it.get("hands", 1)) == 2:
				s += "  (%s)" % Loc.t("two-handed")
		"armor", "accessory":
			if it.has("def"):
				s += "\nDEF +%d" % int(it["def"])
	s += "\n%s: %d %s" % [Loc.t("Price"), int(it.get("price", 0)), Loc.t("coins")]
	return s


static func clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()
