class_name BoardHUD
extends Control
## Board HUD: top status bar, status icons, minimap, message log, dice panel.

signal roll_pressed
signal bag_pressed
signal map_pressed
signal guide_pressed
signal menu_pressed

var hp_bar: ProgressBar
var hp_lbl: Label
var mind_bar: ProgressBar
var mind_lbl: Label
var hunger_bar: ProgressBar
var hunger_lbl: Label
var gold_lbl: Label
var lvl_lbl: Label
var exp_bar: ProgressBar
var stage_lbl: Label
var status_box: HBoxContainer
var minimap: MapView
var log_box: VBoxContainer
var dice_rect: TextureRect
var dice_lbl: Label
var roll_btn: Button
var hint_lbl: Label
var bag_btn: Button
var guide_btn: Button
var menu_btn: Button
var map_panel: PanelContainer
var map_lbl: Label
var top_panel: PanelContainer
var dice_panel: PanelContainer
var log_panel: PanelContainer
var dir_panel: PanelContainer
var dir_box: HBoxContainer
var tile_info: PanelContainer
var tile_info_lbl: RichTextLabel
var portrait: TextureRect
var insane_overlay: ColorRect
var blind_overlay: TextureRect
var _log_entries: Array = []


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void:
	insane_overlay = ColorRect.new()
	insane_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	insane_overlay.color = Color(0.35, 0.0, 0.4, 0.0)
	insane_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(insane_overlay)
	# Blind: dark vignette around the player (the board stays readable in the middle)
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.35, 0.75, 1.0])
	g.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color(0.02, 0.0, 0.03, 0.75), Color(0.02, 0.0, 0.03, 0.95)])
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 160
	gt.height = 90
	blind_overlay = TextureRect.new()
	blind_overlay.texture = gt
	blind_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	blind_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	blind_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	blind_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	blind_overlay.visible = false
	add_child(blind_overlay)
	_build_top()
	_build_minimap()
	_build_log()
	_build_dice()
	_build_tile_info()
	for ctrl in [top_panel, map_panel, dice_panel, log_panel, roll_btn, bag_btn, guide_btn, menu_btn]:
		if is_instance_valid(ctrl):
			ctrl.mouse_entered.connect(func(): show_tile_info("", Vector2.ZERO))
	Game.stats_changed.connect(refresh)
	Game.status_changed.connect(refresh)
	Loc.language_changed.connect(func(_l): refresh())
	refresh()


# ---------------------------------------------------------------- top bar
func _build_top() -> void:
	top_panel = UI.panel("PanelDark")
	top_panel.position = Vector2(0, 0)
	top_panel.size = Vector2(640, 30)
	top_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(top_panel)
	var h := UI.hbox(6)
	top_panel.add_child(h)
	portrait = UI.icon_rect(load("res://assets/gen/chars/player_front.png"))
	portrait.custom_minimum_size = Vector2(20, 20)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	h.add_child(portrait)
	var nv := UI.vbox(0)
	h.add_child(nv)
	lvl_lbl = UI.label("", Color("#ffd86a"))
	nv.add_child(lvl_lbl)
	exp_bar = UI.bar(UI.BAR_EXP, 54, 3)
	nv.add_child(exp_bar)
	var r1 := _mini_stat("hp", UI.BAR_HP)
	hp_bar = r1[0]; hp_lbl = r1[1]; h.add_child(r1[2])
	var r2 := _mini_stat("mind", UI.BAR_MIND)
	mind_bar = r2[0]; mind_lbl = r2[1]; h.add_child(r2[2])
	var r3 := _mini_stat("hunger", UI.BAR_HUNGER)
	hunger_bar = r3[0]; hunger_lbl = r3[1]; h.add_child(r3[2])
	var gh := UI.hbox(2)
	gh.add_child(UI.icon_rect(DB.icon("gold")))
	gold_lbl = UI.label("0", Color("#ffe86a"))
	gh.add_child(gold_lbl)
	h.add_child(gh)
	h.add_child(UI.spacer(0, 0, true))
	stage_lbl = UI.label("", Color("#c8b8e0"))
	h.add_child(stage_lbl)
	# status icons under the bar
	status_box = UI.hbox(1)
	status_box.position = Vector2(6, 32)
	status_box.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(status_box)


func _mini_stat(ic: String, col: Color) -> Array:
	var box := UI.hbox(2)
	box.add_child(UI.icon_rect(DB.icon(ic)))
	var v := UI.vbox(0)
	box.add_child(v)
	var l := UI.label("")
	v.add_child(l)
	var b := UI.bar(col, 56, 4)
	v.add_child(b)
	box.tooltip_text = Loc.t({"hp": "Body / HP. Reaches 0 = death.", "mind": "Mind / Sanity. Used for Skills. Reaches 0 = Insanity.",
		"hunger": "Satiety. Decreases each step. Eat to refill."}[ic])
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	return [b, l, box]


# ---------------------------------------------------------------- minimap
func _build_minimap() -> void:
	map_panel = UI.panel("PanelDark")
	map_panel.position = Vector2(536, 34)
	map_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	map_panel.tooltip_text = Loc.t("Click / [M] to open map")
	add_child(map_panel)
	var v := UI.vbox(1)
	map_panel.add_child(v)
	var hl := UI.hbox(2)
	map_lbl = UI.label(Loc.t("MAP"), Color("#ffd86a"))
	hl.add_child(map_lbl)
	hl.add_child(UI.spacer(0, 0, true))
	hl.add_child(UI.label("[M]", Color(), "DimLabel"))
	v.add_child(hl)
	minimap = MapView.new()
	minimap.setup(6, 4)
	minimap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(minimap)
	map_panel.gui_input.connect(func(e): if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT: map_pressed.emit())


# ---------------------------------------------------------------- log
func _build_log() -> void:
	log_panel = UI.panel("PanelDark")
	log_panel.position = Vector2(4, 292)
	log_panel.size = Vector2(300, 64)
	log_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(log_panel)
	log_box = UI.vbox(0)
	log_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	log_panel.add_child(log_box)


func clear_log() -> void:
	_log_entries.clear()
	if is_instance_valid(log_box):
		UI.clear(log_box)


func push_log(text: String, col: Color = Color("#e8dcc8")) -> void:
	_log_entries.append([text, col])
	while _log_entries.size() > 4:
		_log_entries.pop_front()
	UI.clear(log_box)
	for i in _log_entries.size():
		var e: Array = _log_entries[i]
		var l := UI.label(("• " if i == _log_entries.size() - 1 else "  ") + e[0], e[1])
		l.clip_text = true
		l.custom_minimum_size = Vector2(288, 0)
		if i < _log_entries.size() - 1:
			l.modulate.a = 0.55 + 0.15 * i
		log_box.add_child(l)


# ---------------------------------------------------------------- dice
func _build_dice() -> void:
	dice_panel = UI.panel()
	dice_panel.position = Vector2(456, 270)
	dice_panel.size = Vector2(180, 86)
	dice_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dice_panel)
	var h := UI.hbox(6)
	dice_panel.add_child(h)
	var dv := UI.vbox(1)
	h.add_child(dv)
	dice_rect = TextureRect.new()
	dice_rect.texture = load("res://assets/gen/dice/die_6.png")
	dice_rect.custom_minimum_size = Vector2(48, 48)
	dice_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dice_rect.stretch_mode = TextureRect.STRETCH_SCALE
	dice_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	dice_rect.pivot_offset = Vector2(24, 24)
	dv.add_child(dice_rect)
	dice_lbl = UI.label("", Color("#ffd86a"))
	dice_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dv.add_child(dice_lbl)
	var bv := UI.vbox(2)
	bv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(bv)
	roll_btn = UI.button(Loc.t("ROLL!"), func(): roll_pressed.emit(), DB.icon("dice"))
	roll_btn.custom_minimum_size = Vector2(0, 22)
	roll_btn.tooltip_text = Loc.t("Roll dice [Space]")
	bv.add_child(roll_btn)
	var row := UI.hbox(2)
	bv.add_child(row)
	bag_btn = UI.button(Loc.t("Bag"), func(): bag_pressed.emit())
	bag_btn.tooltip_text = Loc.t("Bag & Equipment [I]")
	bag_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bag_btn)
	guide_btn = UI.button(Loc.t("Guide"), func(): guide_pressed.emit())
	guide_btn.tooltip_text = Loc.t("Guide Book [G]")
	guide_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(guide_btn)
	menu_btn = UI.button(Loc.t("Menu"), func(): menu_pressed.emit())
	menu_btn.tooltip_text = Loc.t("Menu [Esc]")
	menu_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(menu_btn)
	hint_lbl = UI.label(Loc.t("[Space] Roll"), Color(), "DimLabel")
	bv.add_child(hint_lbl)
	# On-screen directional choice panel for mobile and mouse
	dir_panel = UI.panel("PanelDark")
	dir_panel.position = Vector2(456, 238)
	dir_panel.size = Vector2(180, 28)
	dir_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	dir_panel.visible = false
	add_child(dir_panel)
	dir_box = UI.hbox(3)
	dir_box.alignment = BoxContainer.ALIGNMENT_CENTER
	dir_panel.add_child(dir_box)


func show_direction_buttons(dirs_map: Dictionary, on_pick: Callable) -> void:
	UI.clear(dir_box)
	dir_panel.visible = true
	var order := [
		[Vector2i(-1, 0), "← Kiri" if Loc.lang == "id" else "← Left"],
		[Vector2i(0, -1), "↑ Atas" if Loc.lang == "id" else "↑ Up"],
		[Vector2i(0, 1), "↓ Bawah" if Loc.lang == "id" else "↓ Down"],
		[Vector2i(1, 0), "→ Kanan" if Loc.lang == "id" else "→ Right"],
	]
	for item in order:
		var d: Vector2i = item[0]
		if dirs_map.has(d):
			var tile_id: int = dirs_map[d]
			var b := UI.button(item[1], func():
				hide_direction_buttons()
				on_pick.call(tile_id)
			)
			b.custom_minimum_size = Vector2(38, 20)
			dir_box.add_child(b)


func hide_direction_buttons() -> void:
	if is_instance_valid(dir_panel):
		dir_panel.visible = false
		if is_instance_valid(dir_box):
			UI.clear(dir_box)


func set_roll_enabled(on: bool, hint: String = "") -> void:
	roll_btn.disabled = not on
	if hint != "":
		hint_lbl.text = hint
	else:
		hint_lbl.text = Loc.t("[Space] Roll") if on else "..."


func show_die(n: int) -> void:
	dice_rect.texture = load("res://assets/gen/dice/die_%d.png" % clampi(n, 1, 6))


# ---------------------------------------------------------------- tile info
func _build_tile_info() -> void:
	tile_info = UI.panel("PanelDark")
	tile_info.visible = false
	tile_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tile_info)
	tile_info_lbl = UI.rich()
	tile_info_lbl.custom_minimum_size = Vector2(140, 0)
	tile_info_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile_info.add_child(tile_info_lbl)


func show_tile_info(text: String, at: Vector2) -> void:
	if text == "":
		tile_info.visible = false
		return
	tile_info_lbl.text = text
	tile_info.visible = true
	tile_info.reset_size()
	var p := at + Vector2(12, 10)
	p.x = minf(p.x, 640 - tile_info.size.x - 4)
	p.y = minf(p.y, 360 - tile_info.size.y - 4)
	tile_info.position = p


func is_mouse_over_ui() -> bool:
	var ctrl := get_viewport().gui_get_hovered_control()
	if ctrl != null and ctrl != self and ctrl != insane_overlay and ctrl != blind_overlay and ctrl != tile_info and ctrl != tile_info_lbl:
		return true
	var mp := get_viewport().get_mouse_position()
	for p in [top_panel, map_panel, dice_panel, log_panel, dir_panel]:
		if is_instance_valid(p) and p.visible and p.get_global_rect().has_point(mp):
			return true
	return false


# ---------------------------------------------------------------- refresh
func refresh() -> void:
	if not is_instance_valid(hp_bar):
		return
	lvl_lbl.text = "%s Lv.%d" % [Game.player_name, Game.level]
	exp_bar.max_value = Game.exp_needed()
	exp_bar.value = Game.xp
	hp_bar.max_value = Game.max_hp()
	hp_bar.value = Game.hp
	hp_lbl.text = "%d/%d" % [Game.hp, Game.max_hp()]
	mind_bar.max_value = Game.max_mind()
	mind_bar.value = Game.mind
	mind_lbl.text = "%d/%d" % [Game.mind, Game.max_mind()]
	hunger_bar.max_value = 100
	hunger_bar.value = Game.hunger
	hunger_lbl.text = Loc.t("Satiety %d") % Game.hunger
	gold_lbl.text = str(Game.gold)
	stage_lbl.text = "Stage %d%s • %s" % [Game.stage, (" +%d" % (Game.cycle - 1)) if Game.cycle > 1 else "", DB.stage_name(Game.stage)]
	hp_lbl.add_theme_color_override("font_color", Color("#e85a42") if Game.hp < Game.max_hp() * 0.3 else Color("#ece0c8"))
	if roll_btn:
		roll_btn.text = Loc.t("ROLL!")
		roll_btn.tooltip_text = Loc.t("Roll dice [Space]")
	if bag_btn:
		bag_btn.text = Loc.t("Bag")
		bag_btn.tooltip_text = Loc.t("Bag & Equipment [I]")
	if guide_btn:
		guide_btn.text = Loc.t("Guide")
		guide_btn.tooltip_text = Loc.t("Guide Book [G]")
	if menu_btn:
		menu_btn.text = Loc.t("Menu")
		menu_btn.tooltip_text = Loc.t("Menu [Esc]")
	if map_lbl:
		map_lbl.text = Loc.t("MAP")
	if map_panel:
		map_panel.tooltip_text = Loc.t("Click / [M] to open map")
	UI.clear(status_box)
	for id in Game.statuses:
		var r := UI.icon_rect(DB.status_icon(id))
		var st: Dictionary = Game.statuses[id]
		r.tooltip_text = "%s\n%s" % [DB.status_name(id, int(st["stacks"])), DB.status_desc(id)]
		status_box.add_child(r)
	insane_overlay.color.a = 0.12 if Game.has("insane") else 0.0
	blind_overlay.visible = Game.has("blind")

	if minimap:
		minimap.queue_redraw()
