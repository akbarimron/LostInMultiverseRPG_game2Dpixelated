class_name ThemeBuilder
extends RefCounted
## Builds the pixel UI theme (semi-horror, friendly) from generated textures.

const G := "res://assets/gen/"
const TXT := Color("#ece0c8")
const TXT_DIM := Color("#8a7e96")
const ACCENT := Color("#ffd86a")
const SHADOW := Color(0, 0, 0, 0.75)


static func tex_box(path: String, margin: int, content: int = 4) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load(path)
	sb.texture_margin_left = margin
	sb.texture_margin_top = margin
	sb.texture_margin_right = margin
	sb.texture_margin_bottom = margin
	sb.content_margin_left = content
	sb.content_margin_right = content
	sb.content_margin_top = content
	sb.content_margin_bottom = content
	return sb


static func flat(col: Color, border: Color = Color(0, 0, 0, 0), bw: int = 0, content: int = 0) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.anti_aliasing = false
	if bw > 0:
		sb.border_color = border
		sb.set_border_width_all(bw)
	sb.content_margin_left = content
	sb.content_margin_right = content
	sb.content_margin_top = content
	sb.content_margin_bottom = content
	return sb


static func build() -> Theme:
	var t := Theme.new()
	var font: Font = load(G + "fonts/pixel.fnt")
	t.default_font = font
	t.default_font_size = 10

	# Label
	t.set_color("font_color", "Label", TXT)
	t.set_color("font_shadow_color", "Label", SHADOW)
	t.set_constant("shadow_offset_x", "Label", 1)
	t.set_constant("shadow_offset_y", "Label", 1)
	t.set_constant("line_spacing", "Label", 1)

	# Panels
	var panel := tex_box(G + "ui/panel.png", 6, 7)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "Panel", panel)
	t.set_type_variation("PanelRed", "PanelContainer")
	t.set_stylebox("panel", "PanelRed", tex_box(G + "ui/panel_red.png", 6, 7))
	t.set_type_variation("PanelDark", "PanelContainer")
	t.set_stylebox("panel", "PanelDark", tex_box(G + "ui/panel_dark.png", 6, 5))
	t.set_type_variation("PanelClear", "PanelContainer")
	t.set_stylebox("panel", "PanelClear", StyleBoxEmpty.new())

	# Buttons
	t.set_stylebox("normal", "Button", tex_box(G + "ui/btn_normal.png", 4, 4))
	t.set_stylebox("hover", "Button", tex_box(G + "ui/btn_hover.png", 4, 4))
	t.set_stylebox("pressed", "Button", tex_box(G + "ui/btn_pressed.png", 4, 4))
	t.set_stylebox("disabled", "Button", tex_box(G + "ui/btn_disabled.png", 4, 4))
	t.set_stylebox("focus", "Button", tex_box(G + "ui/btn_hover.png", 4, 4))
	t.set_stylebox("hover_pressed", "Button", tex_box(G + "ui/btn_pressed.png", 4, 4))
	t.set_color("font_color", "Button", TXT)
	t.set_color("font_hover_color", "Button", ACCENT)
	t.set_color("font_focus_color", "Button", ACCENT)
	t.set_color("font_pressed_color", "Button", Color("#c8941e"))
	t.set_color("font_hover_pressed_color", "Button", ACCENT)
	t.set_color("font_disabled_color", "Button", Color("#5a5266"))
	t.set_color("font_shadow_color", "Button", SHADOW)
	t.set_color("icon_normal_color", "Button", Color.WHITE)
	t.set_color("icon_disabled_color", "Button", Color(1, 1, 1, 0.35))
	t.set_constant("h_separation", "Button", 4)
	t.set_constant("shadow_offset_x", "Button", 1)
	t.set_constant("shadow_offset_y", "Button", 1)

	# flat "list" button variation (menus, inventory rows)
	t.set_type_variation("ListButton", "Button")
	t.set_stylebox("normal", "ListButton", flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 2))
	t.set_stylebox("hover", "ListButton", flat(Color("#2a2238"), Color("#c8941e"), 1, 2))
	t.set_stylebox("focus", "ListButton", flat(Color("#2a2238"), Color("#ffd86a"), 1, 2))
	t.set_stylebox("pressed", "ListButton", flat(Color("#3a2c4a"), Color("#ffd86a"), 1, 2))
	t.set_stylebox("hover_pressed", "ListButton", flat(Color("#3a2c4a"), Color("#ffd86a"), 1, 2))
	t.set_stylebox("disabled", "ListButton", flat(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 2))

	# Tabs-like toggle variation
	t.set_type_variation("TabButton", "Button")
	t.set_stylebox("normal", "TabButton", flat(Color("#120f19"), Color("#3a3048"), 1, 3))
	t.set_stylebox("hover", "TabButton", flat(Color("#2a2238"), Color("#c8941e"), 1, 3))
	t.set_stylebox("pressed", "TabButton", flat(Color("#3a2c4a"), Color("#ffd86a"), 1, 3))
	t.set_stylebox("hover_pressed", "TabButton", flat(Color("#3a2c4a"), Color("#ffd86a"), 1, 3))
	t.set_stylebox("focus", "TabButton", flat(Color(0, 0, 0, 0), Color("#ffd86a"), 1, 3))

	# Progress bars (defaults; per-bar fill overridden in code)
	t.set_stylebox("background", "ProgressBar", flat(Color("#0c0910"), Color("#07050b"), 1))
	t.set_stylebox("fill", "ProgressBar", flat(Color("#b02a32")))
	t.set_color("font_color", "ProgressBar", TXT)

	# RichTextLabel
	for k in ["normal_font", "bold_font", "italics_font", "mono_font", "bold_italics_font"]:
		t.set_font(k, "RichTextLabel", font)
	for k in ["normal_font_size", "bold_font_size", "italics_font_size", "mono_font_size", "bold_italics_font_size"]:
		t.set_font_size(k, "RichTextLabel", 10)
	t.set_color("default_color", "RichTextLabel", TXT)
	t.set_color("font_shadow_color", "RichTextLabel", SHADOW)
	t.set_constant("shadow_offset_x", "RichTextLabel", 1)
	t.set_constant("shadow_offset_y", "RichTextLabel", 1)
	t.set_constant("line_separation", "RichTextLabel", 1)

	# Tooltip
	t.set_stylebox("panel", "TooltipPanel", tex_box(G + "ui/panel_dark.png", 6, 5))
	t.set_color("font_color", "TooltipLabel", TXT)
	t.set_color("font_shadow_color", "TooltipLabel", SHADOW)
	t.set_constant("shadow_offset_x", "TooltipLabel", 1)
	t.set_constant("shadow_offset_y", "TooltipLabel", 1)

	# Scrollbars
	var grab := flat(Color("#5c4c74"))
	var grab_h := flat(Color("#c8941e"))
	for sb_type in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", sb_type, flat(Color("#0c0910"), Color(), 0, 1))
		t.set_stylebox("scroll_focus", sb_type, flat(Color("#0c0910"), Color(), 0, 1))
		t.set_stylebox("grabber", sb_type, grab)
		t.set_stylebox("grabber_highlight", sb_type, grab_h)
		t.set_stylebox("grabber_pressed", sb_type, grab_h)
	t.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())

	# LineEdit
	t.set_stylebox("normal", "LineEdit", flat(Color("#0c0910"), Color("#5c4c74"), 1, 4))
	t.set_stylebox("focus", "LineEdit", flat(Color("#0c0910"), Color("#ffd86a"), 1, 4))
	t.set_color("font_color", "LineEdit", TXT)
	t.set_color("caret_color", "LineEdit", ACCENT)
	t.set_color("selection_color", "LineEdit", Color("#5c4c74"))

	# Separator
	var sep := flat(Color("#3a3048"))
	sep.content_margin_top = 1
	sep.content_margin_bottom = 1
	t.set_stylebox("separator", "HSeparator", sep)
	t.set_constant("separation", "HSeparator", 4)

	# Small text variation
	t.set_type_variation("DimLabel", "Label")
	t.set_color("font_color", "DimLabel", TXT_DIM)
	t.set_type_variation("TitleLabel", "Label")
	t.set_color("font_color", "TitleLabel", ACCENT)
	t.set_font_size("font_size", "TitleLabel", 10)
	t.set_type_variation("BigLabel", "Label")
	t.set_font_size("font_size", "BigLabel", 20)
	t.set_color("font_color", "BigLabel", ACCENT)
	t.set_constant("shadow_offset_x", "BigLabel", 2)
	t.set_constant("shadow_offset_y", "BigLabel", 2)
	return t
