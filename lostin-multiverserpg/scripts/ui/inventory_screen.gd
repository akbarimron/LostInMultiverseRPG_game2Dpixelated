class_name InventoryScreen
extends Control
## Bag / equipment / crafting / status / skill screen (board only).

signal closed
signal used_item(msgs: Array)

var tab := "tas"
var filter := "all"
var selected := ""
var left_box: VBoxContainer
var mid_box: VBoxContainer
var right_box: VBoxContainer
var tab_buttons := {}


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	add_child(UI.dim_bg())
	var root := UI.panel()
	root.position = Vector2(14, 12)
	root.size = Vector2(612, 336)
	add_child(root)
	var v := UI.vbox(4)
	root.add_child(v)
	# header
	var head := UI.hbox(4)
	v.add_child(head)
	head.add_child(UI.icon_rect(DB.item_icon("kantong")))
	head.add_child(UI.label(Loc.t("BAG & EQUIPMENT"), Color(), "TitleLabel"))
	head.add_child(UI.spacer(8))
	for t in [["tas", "Bag"], ["racik", "Craft"], ["status", "Condition"], ["skill", "Skills"]]:
		var key: String = t[0]
		var b := UI.button(Loc.t(t[1]), func(): _set_tab(key), null, "TabButton")
		b.toggle_mode = true
		tab_buttons[key] = b
		head.add_child(b)
	head.add_child(UI.spacer(0, 0, true))
	head.add_child(UI.button(Loc.t("Close [Esc]"), _close))
	v.add_child(HSeparator.new())
	var body := UI.hbox(6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(body)
	left_box = UI.vbox(3)
	left_box.custom_minimum_size = Vector2(170, 0)
	body.add_child(left_box)
	var mid_panel := UI.panel("PanelDark")
	mid_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(mid_panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 270)
	mid_panel.add_child(scroll)
	mid_box = UI.vbox(3)
	mid_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(mid_box)
	var rp := UI.panel("PanelDark")
	rp.custom_minimum_size = Vector2(160, 0)
	body.add_child(rp)
	right_box = UI.vbox(4)
	rp.add_child(right_box)
	Game.stats_changed.connect(_refresh_left)
	_set_tab("tas")


func _close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_I, KEY_TAB]:
			get_viewport().set_input_as_handled()
			_close()


func _set_tab(t: String) -> void:
	tab = t
	for k in tab_buttons:
		tab_buttons[k].button_pressed = (k == t)
	_refresh()


func _refresh() -> void:
	_refresh_left()
	_refresh_mid()
	_refresh_right()


# ---------------------------------------------------------------- left: character
func _refresh_left() -> void:
	if not is_instance_valid(left_box):
		return
	UI.clear(left_box)
	var top := UI.hbox(4)
	left_box.add_child(top)
	top.add_child(UI.icon_rect(load("res://assets/gen/chars/player_front.png"), 2))
	var nv := UI.vbox(1)
	top.add_child(nv)
	nv.add_child(UI.label(Game.player_name, Color("#ffd86a")))
	nv.add_child(UI.label(Loc.t("High-schooler  Lv.%d") % Game.level, Color(), "DimLabel"))
	nv.add_child(UI.label("EXP %d/%d" % [Game.xp, Game.exp_needed()], Color(), "DimLabel"))
	nv.add_child(UI.label(Loc.t("Phobia:") + " " + Loc.t(DB.PHOBIAS[Game.phobia]["name"]).split(" ")[0], Color("#c64c98")))
	left_box.add_child(_stat_bar("hp", "HP", Game.hp, Game.max_hp(), UI.BAR_HP))
	left_box.add_child(_stat_bar("mind", "Mind", Game.mind, Game.max_mind(), UI.BAR_MIND))
	left_box.add_child(_stat_bar("hunger", Loc.t("Hunger"), Game.hunger, 100, UI.BAR_HUNGER))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 0)
	left_box.add_child(grid)
	for row in [["atk", "ATK", Game.atk()], ["def", "DEF", Game.defense()], ["agi", "AGI", Game.agi()], ["luck", "LUCK", Game.luck()],
			["atk", Loc.t("Accuracy"), "%d%%" % Game.accuracy()], ["exp", Loc.t("Crit"), "%d%%" % Game.crit_chance()], ["dice", Loc.t("Dice"), "%+d" % Game.dice_mod()]]:
		var h := UI.hbox(2)
		h.add_child(UI.icon_rect(DB.icon(row[0])))
		h.add_child(UI.label("%s %s" % [row[1], str(row[2])]))
		grid.add_child(h)
	left_box.add_child(HSeparator.new())
	for slot in [["weapon", "Weapon"], ["armor", "Armor"], ["accessory", "Accessory"]]:
		var sid: String = slot[0]
		var id: String = Game.equip.get(sid, "")
		var b := Button.new()
		b.theme_type_variation = "ListButton"
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = "%s: %s" % [Loc.t(slot[1]), DB.item_name(id) if id != "" else "-"]
		if id != "":
			b.icon = DB.item_icon(id)
			b.tooltip_text = UI.item_tooltip(id) + "\n" + Loc.t("(Click to unequip)")
		b.pressed.connect(func(): _unequip(sid))
		left_box.add_child(b)


func _stat_bar(ic: String, name_: String, v: int, mx: int, col: Color) -> Control:
	var h := UI.hbox(3)
	h.add_child(UI.icon_rect(DB.icon(ic)))
	var b := UI.bar(col, 70, 6)
	b.max_value = mx
	b.value = v
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(b)
	h.add_child(UI.label("%d/%d" % [v, mx]))
	return h


func _unequip(slot: String) -> void:
	Game.unequip(slot)
	Sfx.play("select")
	_refresh()


# ---------------------------------------------------------------- middle
func _refresh_mid() -> void:
	UI.clear(mid_box)
	match tab:
		"tas":
			_mid_bag()
		"racik":
			_mid_craft()
		"status":
			_mid_status()
		"skill":
			_mid_skills()


func _mid_bag() -> void:
	var fh := UI.hbox(2)
	mid_box.add_child(fh)
	for f in [["all", "All"], ["consumable", "Consumables"], ["gear", "Gear"], ["material", "Materials"]]:
		var key: String = f[0]
		var b := UI.button(Loc.t(f[1]), func(): filter = key; _refresh_mid(), null, "TabButton")
		b.toggle_mode = true
		b.button_pressed = filter == key
		fh.add_child(b)
	var grid := GridContainer.new()
	grid.columns = 9
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	mid_box.add_child(grid)
	var ids: Array = Game.inventory.keys()
	ids.sort_custom(func(a, b): return _kind_order(a) < _kind_order(b))
	var n := 0
	for id in ids:
		var k: String = DB.item(id).get("kind", "")
		if filter == "consumable" and k != "consumable":
			continue
		if filter == "material" and k != "material":
			continue
		if filter == "gear" and not k in ["weapon", "armor", "accessory"]:
			continue
		grid.add_child(_slot(id, Game.count(id)))
		n += 1
	if n == 0:
		mid_box.add_child(UI.label(Loc.t("(empty)"), Color(), "DimLabel"))
	mid_box.add_child(UI.spacer(0, 4))
	mid_box.add_child(UI.label("%s: %d" % [Loc.t("Coins"), Game.gold], Color("#ffe86a")))


func _kind_order(id: String) -> int:
	return ["consumable", "weapon", "armor", "accessory", "material"].find(DB.item(id).get("kind", "")) * 1000 + int(DB.item(id).get("price", 0))


func _slot(id: String, cnt: int) -> Control:
	var b := Button.new()
	b.custom_minimum_size = Vector2(24, 24)
	b.theme_type_variation = "ListButton"
	b.icon = DB.item_icon(id)
	b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b.tooltip_text = UI.item_tooltip(id)
	b.pressed.connect(func(): _select(id))
	var base := "equip" if id == selected else "normal"
	for st in ["normal", "disabled"]:
		b.add_theme_stylebox_override(st, ThemeBuilder.tex_box("res://assets/gen/ui/slot_%s.png" % base, 3, 2))
	for st in ["hover", "focus", "pressed", "hover_pressed"]:
		b.add_theme_stylebox_override(st, ThemeBuilder.tex_box("res://assets/gen/ui/slot_hover.png", 3, 2))
	if cnt > 1:
		var l := UI.label(str(cnt))
		l.position = Vector2(14, 12)
		l.add_theme_color_override("font_color", Color.WHITE)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(l)
	return b


func _mid_craft() -> void:
	mid_box.add_child(UI.label(Loc.t("Craft materials into useful items:"), Color(), "DimLabel"))
	for r in DB.RECIPES:
		var row := UI.hbox(3)
		var ok := Game.can_craft(r)
		row.add_child(UI.icon_rect(DB.item_icon(r["out"])))
		var nm := UI.label(DB.item_name(r["out"]), Color("#ffd86a") if ok else Color("#8a7e96"))
		nm.custom_minimum_size = Vector2(84, 0)
		row.add_child(nm)
		row.add_child(UI.label("=", Color(), "DimLabel"))
		for k in r["in"]:
			var have := Game.count(k)
			var need: int = r["in"][k]
			var ic := UI.icon_rect(DB.item_icon(k))
			ic.tooltip_text = "%s (%d/%d)" % [DB.item_name(k), have, need]
			ic.modulate = Color.WHITE if have >= need else Color(1, 1, 1, 0.35)
			row.add_child(ic)
			row.add_child(UI.label("x%d" % need, Color("#7ec45c") if have >= need else Color("#e85a42")))
		row.add_child(UI.spacer(0, 0, true))
		var rr: Dictionary = r
		var b := UI.button(Loc.t("Craft"), func(): _do_craft(rr))
		b.disabled = not ok
		row.add_child(b)
		mid_box.add_child(row)


func _do_craft(r: Dictionary) -> void:
	if Game.craft(r):
		Sfx.play("buy")
		Game.emit_signal("message", Loc.t("Crafted %s!") % DB.item_name(r["out"]), Game.C_GOOD)
		selected = r["out"]
		_refresh()


func _mid_status() -> void:
	if Game.statuses.is_empty():
		mid_box.add_child(UI.label(Loc.t("You are in perfect shape. For now..."), Color("#7ec45c")))
	for id in Game.statuses:
		var st: Dictionary = Game.statuses[id]
		var row := UI.hbox(4)
		row.add_child(UI.icon_rect(DB.status_icon(id)))
		var r := UI.rich("[color=%s]%s[/color]\n[color=#a89ab8]%s[/color]" % [
			"#e85a42" if DB.STATUS[id]["bad"] else "#7ec45c", DB.status_name(id, int(st["stacks"])), DB.status_desc(id)], true, 230)
		r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(r)
		mid_box.add_child(row)
	mid_box.add_child(HSeparator.new())
	mid_box.add_child(UI.rich("[color=#c64c98]%s:[/color] %s\n%s" % [Loc.t("Phobia"), Loc.t(DB.PHOBIAS[Game.phobia]["name"]), Loc.t("Facing what you fear adds [color=#e85a42]Fear[/color].")], true, 250))
	mid_box.add_child(UI.rich("[color=#d8861e]%s:[/color] %d/100. %s" % [Loc.t("Satiety"), Game.hunger, Loc.t("Every step drains your food. Eat before you starve!")], true, 250))


func _mid_skills() -> void:
	for id in DB.SKILLS:
		var s: Dictionary = DB.SKILLS[id]
		var have := Game.skills.has(id)
		var r := UI.rich("[color=%s]%s[/color]  [color=#9c8cff]%d Mind[/color]  %s\n[color=#a89ab8]%s[/color]" % [
			"#ffd86a" if have else "#5a5266", DB.skill_name(id), int(s["mind"]), "" if have else "[color=#5a5266](Lv.%d)[/color]" % int(s["lv"]), DB.skill_desc(id)], true, 250)
		mid_box.add_child(r)


# ---------------------------------------------------------------- right: details
func _refresh_right() -> void:
	UI.clear(right_box)
	if tab != "tas" or selected == "" or Game.count(selected) <= 0:
		right_box.add_child(UI.label(Loc.t("Select an item"), Color(), "DimLabel"))
		right_box.add_child(UI.rich(Loc.t("Tip: click an equipment slot on the left to unequip. Materials can be combined in the Craft tab."), true, 146))
		return
	var it := DB.item(selected)
	var c := CenterContainer.new()
	c.add_child(UI.icon_rect(DB.item_icon(selected), 3))
	right_box.add_child(c)
	right_box.add_child(UI.label(DB.item_name(selected), Color("#ffd86a")))
	right_box.add_child(UI.label("%s  x%d" % [DB.kind_label(it["kind"]), Game.count(selected)], Color(), "DimLabel"))
	var d := UI.rich(UI.item_tooltip(selected).split("\n", true, 1)[1] if UI.item_tooltip(selected).contains("\n") else "")
	right_box.add_child(d)
	var k: String = it["kind"]
	if k == "consumable":
		var b := UI.button(Loc.t("Use"), _use_selected)
		b.disabled = it.get("use", "both") == "battle"
		if b.disabled:
			b.tooltip_text = Loc.t("Can only be used in battle")
		right_box.add_child(b)
	elif k in ["weapon", "armor", "accessory"]:
		right_box.add_child(UI.button(Loc.t("Equip"), _equip_selected))
	right_box.add_child(UI.button(Loc.t("Drop 1"), _drop_selected))


func _select(id: String) -> void:
	selected = id
	Sfx.play("move")
	_refresh_mid()
	_refresh_right()


func _use_selected() -> void:
	var id := selected
	var it := DB.item(id)
	if id == "kunci":
		Game.emit_signal("message", Loc.t("The key is used automatically when you open a locked chest."), Game.C_INFO)
		return
	var msgs := Game.use_consumable(id)
	Sfx.play("heal" if it.has("heal") or it.has("cure") else "select")
	Game.emit_signal("message", "%s: %s" % [DB.item_name(id), ", ".join(msgs) if not msgs.is_empty() else Loc.t("no effect")], Game.C_GOOD)
	used_item.emit(msgs)
	_refresh()


func _equip_selected() -> void:
	var id := selected
	var it := DB.item(id)
	if it.get("kind") == "weapon" and int(it.get("hands", 1)) == 2 and Game.has("frac_arm"):
		Game.emit_signal("message", Loc.t("Your arm is broken... two-handed weapons are weaker!"), Game.C_WARN)
	Game.equip_item(id)
	Sfx.play("open", 0.05, -6)
	Game.emit_signal("message", Loc.t("Equipped %s.") % DB.item_name(id), Game.C_INFO)
	selected = ""
	_refresh()


func _drop_selected() -> void:
	Game.remove_item(selected)
	Sfx.play("cancel")
	_refresh()
