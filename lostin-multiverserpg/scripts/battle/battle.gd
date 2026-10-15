extends Node2D
## Turn-based battle: Attack (with body-part targeting), Defend, Skill, Item, Flee.
## Enemy attacks can be PARRIED with a timing QTE. Complex Fear&Hunger-like statuses.

const G := "res://assets/gen/"
const FEET_Y := 238.0

signal menu_pick(value)
signal qte_done(grade: int)

var enemies: Array = []
var kind := "enemy"
var tile_id := -1
var is_boss := false
var over := false
var fled := false
var rng: RandomNumberGenerator

# nodes
var arena: Node2D
var bg: Sprite2D
var player_node: Node2D
var player_spr: Sprite2D
var weapon_spr: Sprite2D
var fx_layer: Node2D
var ui: CanvasLayer
var overhead_layer: Control
var menu_box: VBoxContainer
var menu_title: Label
var log_lbl: RichTextLabel
var hint_lbl: Label
var p_name: Label
var p_hp: ProgressBar
var p_hp_lbl: Label
var p_mind: ProgressBar
var p_mind_lbl: Label
var p_status: HBoxContainer
var p_weapon: Label
var target_arrow: Sprite2D
var turn_banner: Label
var qte_panel: PanelContainer
var qte_bar: Control
var qte_guard: ColorRect
var qte_perfect: ColorRect
var qte_cursor: ColorRect
var qte_label: Label
var dialog: GameDialog
var _log: Array = []

# qte state
var qte_active := false
var qte_t := 0.0
var qte_dur := 0.8
var qte_zone := Vector4(0.4, 0.6, 0.47, 0.53)   # guard min/max, perfect min/max
var _anim_t := 0.0
var _player_pose := "idle"
var _shake := 0.0

var tex_cache := {}


func _ready() -> void:
	rng = Game.rng
	var pb: Dictionary = Game.pending_battle
	if pb.is_empty():
		pb = {"enemies": ["preman", "copet"], "tile": -1, "kind": "enemy"}
		if not Game.has_run:
			Game.new_game()
	kind = pb.get("kind", "enemy")
	tile_id = pb.get("tile", -1)
	is_boss = kind == "boss"
	_build_scene()
	_build_ui()
	for id in pb["enemies"]:
		_add_enemy(id)
	_layout_enemies(false)
	Sfx.music("music_battle", 0.6)
	_run.call_deferred()


func _tex(p: String) -> Texture2D:
	if not tex_cache.has(p):
		tex_cache[p] = load(p)
	return tex_cache[p]


# =============================================================== building
func _build_scene() -> void:
	arena = Node2D.new()
	add_child(arena)
	bg = Sprite2D.new()
	bg.texture = _tex(G + "bg/bg_s%d.png" % Game.stage)
	bg.centered = false
	bg.scale = Vector2(2, 2)
	bg.position = Vector2(0, -56)   # put the ground line behind the actors' feet
	bg.modulate = Color(0.78, 0.74, 0.82) if Game.stage != 3 else Color(0.5, 0.42, 0.5)
	arena.add_child(bg)
	# player
	player_node = Node2D.new()
	player_node.position = Vector2(150, FEET_Y)
	player_node.scale = Vector2(2, 2)
	arena.add_child(player_node)
	var sh := Sprite2D.new()
	sh.texture = _tex(G + "ui/shadow.png")
	player_node.add_child(sh)
	player_spr = Sprite2D.new()
	player_spr.texture = _tex(G + "chars/player_idle.png")
	player_spr.offset = Vector2(0, -15)
	player_node.add_child(player_spr)
	weapon_spr = Sprite2D.new()
	weapon_spr.position = Vector2(14, -20)
	weapon_spr.visible = false
	player_node.add_child(weapon_spr)
	fx_layer = Node2D.new()
	arena.add_child(fx_layer)
	target_arrow = Sprite2D.new()
	target_arrow.texture = _tex(G + "ui/arrow_down.png")
	target_arrow.visible = false
	target_arrow.scale = Vector2(2, 2)
	arena.add_child(target_arrow)


func _build_ui() -> void:
	ui = CanvasLayer.new()
	ui.layer = 5
	add_child(ui)
	overhead_layer = Control.new()
	overhead_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	overhead_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(overhead_layer)
	# bottom HUD
	var bottom := UI.panel()
	bottom.position = Vector2(0, 252)
	bottom.size = Vector2(640, 108)
	ui.add_child(bottom)
	var h := UI.hbox(6)
	bottom.add_child(h)
	# player status
	var pv := UI.vbox(2)
	pv.custom_minimum_size = Vector2(176, 0)
	h.add_child(pv)
	var ph := UI.hbox(3)
	pv.add_child(ph)
	ph.add_child(UI.icon_rect(_tex(G + "chars/player_front.png")))
	p_name = UI.label("", Color("#ffd86a"))
	ph.add_child(p_name)
	var r1 := UI.hbox(3)
	r1.add_child(UI.icon_rect(DB.icon("hp")))
	p_hp = UI.bar(UI.BAR_HP, 96, 7)
	p_hp.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r1.add_child(p_hp)
	p_hp_lbl = UI.label("")
	r1.add_child(p_hp_lbl)
	pv.add_child(r1)
	var r2 := UI.hbox(3)
	r2.add_child(UI.icon_rect(DB.icon("mind")))
	p_mind = UI.bar(UI.BAR_MIND, 96, 7)
	p_mind.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	r2.add_child(p_mind)
	p_mind_lbl = UI.label("")
	r2.add_child(p_mind_lbl)
	pv.add_child(r2)
	p_weapon = UI.label("", Color(), "DimLabel")
	pv.add_child(p_weapon)
	p_status = UI.hbox(1)
	pv.add_child(p_status)
	# command menu
	var mp := UI.panel("PanelDark")
	mp.custom_minimum_size = Vector2(196, 0)
	h.add_child(mp)
	var mv := UI.vbox(1)
	mp.add_child(mv)
	menu_title = UI.label("", Color(), "DimLabel")
	mv.add_child(menu_title)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(0, 80)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	mv.add_child(sc)
	menu_box = UI.vbox(0)
	menu_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sc.add_child(menu_box)
	# log
	var lv := UI.vbox(2)
	lv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(lv)
	log_lbl = UI.rich("", false)
	log_lbl.custom_minimum_size = Vector2(0, 80)
	log_lbl.scroll_following = true
	log_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lv.add_child(log_lbl)
	hint_lbl = UI.label("", Color(), "DimLabel")
	hint_lbl.clip_text = true
	hint_lbl.custom_minimum_size = Vector2(230, 0)
	lv.add_child(hint_lbl)
	# turn banner
	turn_banner = UI.label("", Color(), "BigLabel")
	turn_banner.position = Vector2(0, 8)
	turn_banner.size = Vector2(640, 24)
	turn_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_banner.modulate.a = 0
	ui.add_child(turn_banner)
	# guide & settings buttons at top right
	var gb_btn := UI.button(Loc.t("Guide"), func(): _open_guide("combat"))
	gb_btn.name = "GuideBtn"
	gb_btn.position = Vector2(468, 6)
	gb_btn.custom_minimum_size = Vector2(74, 20)
	gb_btn.tooltip_text = Loc.t("Guide Book [G]")
	ui.add_child(gb_btn)
	var sb := UI.button(Loc.t("Settings"), _open_settings)
	sb.name = "SettingsBtn"
	sb.position = Vector2(548, 6)
	sb.custom_minimum_size = Vector2(86, 20)
	sb.tooltip_text = Loc.t("Settings [O]")
	ui.add_child(sb)
	_build_qte()
	_build_condition_panel()
	var top := CanvasLayer.new()
	top.layer = 20
	add_child(top)
	dialog = GameDialog.new()
	top.add_child(dialog)
	Game.stats_changed.connect(_refresh_player)
	Game.status_changed.connect(_refresh_player)
	Loc.language_changed.connect(_on_language_changed)
	_refresh_player()


func _exit_tree() -> void:
	if Game.stats_changed.is_connected(_refresh_player):
		Game.stats_changed.disconnect(_refresh_player)
	if Game.status_changed.is_connected(_refresh_player):
		Game.status_changed.disconnect(_refresh_player)
	if Loc.language_changed.is_connected(_on_language_changed):
		Loc.language_changed.disconnect(_on_language_changed)


func _build_qte() -> void:
	qte_panel = UI.panel("PanelRed")
	qte_panel.position = Vector2(180, 42)
	qte_panel.size = Vector2(280, 40)
	qte_panel.visible = false
	ui.add_child(qte_panel)
	var v := UI.vbox(3)
	qte_panel.add_child(v)
	qte_label = UI.label(Loc.t("PARRY! Press [SPACE] in gold zone"), Color("#ffd86a"))
	qte_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(qte_label)
	qte_bar = ColorRect.new()
	(qte_bar as ColorRect).color = Color("#0c0910")
	qte_bar.custom_minimum_size = Vector2(260, 10)
	v.add_child(qte_bar)
	qte_guard = ColorRect.new()
	qte_guard.color = Color("#8a5a12")
	qte_bar.add_child(qte_guard)
	qte_perfect = ColorRect.new()
	qte_perfect.color = Color("#ffe86a")
	qte_bar.add_child(qte_perfect)
	qte_cursor = ColorRect.new()
	qte_cursor.color = Color.WHITE
	qte_cursor.size = Vector2(2, 14)
	qte_cursor.position = Vector2(0, -2)
	qte_bar.add_child(qte_cursor)


# =============================================================== condition panel (buffs / debuffs)
var cond_title: Label
var cond_list: VBoxContainer
var cond_btn: Button


func _build_condition_panel() -> void:
	var p := UI.panel("PanelDark")
	p.position = Vector2(4, 4)
	p.custom_minimum_size = Vector2(150, 0)
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	ui.add_child(p)
	var v := UI.vbox(1)
	p.add_child(v)
	var head := UI.hbox(4)
	v.add_child(head)
	cond_title = UI.label("", Color("#ffd86a"))
	cond_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(cond_title)
	cond_btn = UI.button("", _show_conditions, null, "ListButton")
	head.add_child(cond_btn)
	cond_list = UI.vbox(0)
	v.add_child(cond_list)


func _duration_text(st: Dictionary) -> String:
	var turns := int(st.get("turns", -1))
	var steps := int(st.get("steps", -1))
	if turns > 0:
		return Loc.t("%d turns") % turns
	if steps > 0:
		return Loc.t("%d steps") % steps
	return ""


func _refresh_conditions() -> void:
	if not is_instance_valid(cond_list):
		return
	cond_title.text = Loc.t("CONDITION")
	cond_btn.text = Loc.t("Check [C]")
	cond_btn.tooltip_text = Loc.t("Details of every buff and debuff on you and the enemies. Free action.")
	UI.clear(cond_list)
	if Game.statuses.is_empty():
		cond_list.add_child(UI.label(Loc.t("No effects"), Color(), "DimLabel"))
		return
	# debuffs first, then buffs
	var ids: Array = Game.statuses.keys()
	ids.sort_custom(func(a, b): return int(DB.STATUS[a]["bad"]) > int(DB.STATUS[b]["bad"]))
	for id in ids:
		var st: Dictionary = Game.statuses[id]
		var bad: bool = DB.STATUS[id]["bad"]
		var row := UI.hbox(3)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		row.tooltip_text = "%s\n%s" % [DB.status_name(id, int(st["stacks"])), DB.status_desc(id)]
		row.add_child(UI.icon_rect(DB.status_icon(id)))
		var nm := UI.label(DB.status_name(id, int(st["stacks"])), Color("#e85a42") if bad else Color("#7ec45c"))
		nm.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(nm)
		var dur := _duration_text(st)
		if dur != "":
			row.add_child(UI.label(dur, Color(), "DimLabel"))
		cond_list.add_child(row)


func _status_lines(statuses: Dictionary, with_desc: bool) -> String:
	if statuses.is_empty():
		return "[color=#8a7e96]%s[/color]" % Loc.t("No effects")
	var s := ""
	for id in statuses:
		var st: Dictionary = statuses[id]
		var col := "#e85a42" if DB.STATUS[id]["bad"] else "#7ec45c"
		var dur := _duration_text(st)
		s += "[color=%s]• %s[/color]%s" % [col, DB.status_name(id, int(st.get("stacks", 1))), (" [color=#8a7e96](%s)[/color]" % dur) if dur != "" else ""]
		if with_desc:
			s += "\n   [color=#a89ab8]%s[/color]" % DB.status_desc(id)
		s += "\n"
	return s


func _show_conditions() -> void:
	if qte_active or over:
		return
	var txt := "[color=#ffd86a]%s (%s)[/color]\n" % [Game.player_name, Loc.t("You")]
	txt += _status_lines(Game.statuses, true)
	for e in _alive():
		txt += "\n[color=#ffd86a]%s[/color]  [color=#8a7e96]HP %d/%d[/color]\n" % [e["name"], int(e["hp"]), int(e["max_hp"])]
		var est: Dictionary = {}
		for k in e["st"]:
			est[k] = {"stacks": e["st"][k].get("stacks", 1), "turns": e["st"][k].get("turns", -1)}
		txt += _status_lines(est, false)
		var broken: Array = []
		for p in e["parts"]:
			if p["broken"]:
				broken.append(DB.part_name(p))
		if not broken.is_empty():
			txt += "[color=#ffa848]• %s: %s[/color]\n" % [Loc.t("Broken parts"), ", ".join(broken)]
	var c: int = await dialog.ask(Loc.t("CONDITIONS"), txt, [Loc.t("Back"), Loc.t("Guide Book [G]")], DB.status_icon("focus"), "", 0)
	if c == 1:
		_open_guide("conditions")


func _refresh_player() -> void:
	_refresh_conditions()
	if not is_instance_valid(p_hp):
		return
	p_name.text = "%s  Lv.%d" % [Game.player_name, Game.level]
	p_hp.max_value = Game.max_hp()
	p_hp.value = Game.hp
	p_hp_lbl.text = "%d/%d" % [Game.hp, Game.max_hp()]
	p_mind.max_value = Game.max_mind()
	p_mind.value = Game.mind
	p_mind_lbl.text = "%d/%d" % [Game.mind, Game.max_mind()]
	p_weapon.text = "%s  ATK %d DEF %d" % [DB.item_name(Game.equip.get("weapon", "w_tangan")), Game.atk(), Game.defense()]
	UI.clear(p_status)
	for id in Game.statuses:
		var r := UI.icon_rect(DB.status_icon(id))
		r.tooltip_text = "%s\n%s" % [DB.status_name(id, Game.stacks(id)), DB.status_desc(id)]
		p_status.add_child(r)


var _menu_open := false


func _on_language_changed(_l: String) -> void:
	# old log lines were written in the previous language -> start a fresh log
	_log.clear()
	if is_instance_valid(log_lbl):
		log_lbl.text = ""
	if _menu_open:
		menu_pick.emit("__relang")
	for e in enemies:
		e["name"] = DB.enemy_name(e["id"])
		if is_instance_valid(e.get("ui_name")):
			e["ui_name"].text = e["name"]
	_refresh_player()
	var gb: Button = ui.get_node_or_null("GuideBtn")
	if gb:
		gb.text = Loc.t("Guide")
		gb.tooltip_text = Loc.t("Guide Book [G]")
	var sb: Button = ui.get_node_or_null("SettingsBtn")
	if sb:
		sb.text = Loc.t("Settings")
		sb.tooltip_text = Loc.t("Settings [O]")
	if is_instance_valid(qte_label):
		qte_label.text = Loc.t("PARRY! [SPACE]/tap in gold zone")


func _open_settings() -> void:
	if qte_active:
		return
	var s := SettingsDialog.new()
	var top := CanvasLayer.new()
	top.layer = 25
	add_child(top)
	top.add_child(s)
	await s.closed
	top.queue_free()
	_on_language_changed(Loc.lang)


func _open_guide(chapter: String = "combat") -> void:
	if qte_active:
		return
	var gb := GuideBook.new()
	gb.start_chapter = chapter
	var top := CanvasLayer.new()
	top.layer = 25
	add_child(top)
	top.add_child(gb)
	await gb.closed
	top.queue_free()


func _open_pause_menu() -> void:
	if qte_active:
		return
	var c := await dialog.ask(Loc.t("PAUSED"), "", [Loc.t("Resume"), Loc.t("Settings [O]"), Loc.t("Guide Book [G]")])
	match c:
		1:
			_open_settings()
		2:
			_open_guide("combat")


# =============================================================== enemies
func _add_enemy(id: String) -> Dictionary:
	var d: Dictionary = DB.ENEMIES[id]
	var mult := 1.0 + 0.45 * (Game.cycle - 1)
	var e := {
		"id": id, "name": DB.enemy_name(id), "max_hp": int(d["hp"] * mult), "hp": int(d["hp"] * mult),
		"atk": float(d["atk"]) * mult, "def": int(d["def"]), "agi": int(d["agi"]), "exp": int(d["exp"] * mult),
		"gold": d["gold"], "tags": d.get("tags", []), "boss": d.get("boss", false), "big": d.get("big", false),
		"alive": true, "fled": false, "arm_broken": false, "leg_broken": false, "blinded": false,
		"st": {}, "stolen_gold": 0, "stolen_items": [], "phase": rng.randf(), "split_done": false,
		"parts": [],
	}
	for p in DB.PARTS[d["parts"]]:
		var part: Dictionary = p.duplicate()
		part["max_hp"] = maxi(1, int(e["max_hp"] * float(p["hp"])))
		part["hp"] = part["max_hp"]
		part["broken"] = false
		e["parts"].append(part)
	var node := Node2D.new()
	node.scale = Vector2(2, 2)
	node.position = Vector2(700, FEET_Y)
	var sh := Sprite2D.new()
	sh.texture = _tex(G + ("ui/shadow_big.png" if e["big"] else "ui/shadow.png"))
	node.add_child(sh)
	var spr := Sprite2D.new()
	spr.texture = DB.enemy_tex(id)
	spr.offset = Vector2(0, -23 if e["big"] else -15)
	node.add_child(spr)
	arena.add_child(node)
	e["node"] = node
	e["spr"] = spr
	# overhead ui
	var box := UI.vbox(0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var nl := UI.label(e["name"], Color("#ece0c8"))
	nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(nl)
	var bar := UI.bar(Color("#c8323a"), 50, 4)
	bar.max_value = e["max_hp"]
	bar.value = e["hp"]
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(bar)
	var stb := UI.hbox(0)
	stb.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(stb)
	overhead_layer.add_child(box)
	e["ui"] = box
	e["ui_name"] = nl
	e["ui_bar"] = bar
	e["ui_st"] = stb
	# clickable area for targeting
	var click := Button.new()
	click.flat = true
	click.focus_mode = Control.FOCUS_NONE
	click.size = Vector2(64, 72) if not e["big"] else Vector2(96, 100)
	click.modulate.a = 0.0
	click.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overhead_layer.add_child(click)
	e["click"] = click
	click.pressed.connect(func(): _on_enemy_clicked(e))
	enemies.append(e)
	return e


func _layout_enemies(animate: bool = true) -> void:
	var alive: Array = []
	for e in enemies:
		if e["alive"]:
			alive.append(e)
	var n := alive.size()
	for i in n:
		var e: Dictionary = alive[i]
		var x := 470.0
		var y := FEET_Y
		if n > 1:
			x = lerpf(400.0, 590.0, float(i) / float(n - 1))
			y = FEET_Y - (10.0 if i % 2 == 0 else -4.0)
		if e["big"]:
			x = 480.0 if n == 1 else x
		var to := Vector2(round(x), y)
		e["home"] = to
		if animate:
			var tw := create_tween()
			tw.tween_property(e["node"], "position", to, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			e["node"].position = to + Vector2(240, 0)
			var tw2 := create_tween()
			tw2.tween_property(e["node"], "position", to, 0.5 + i * 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_overheads() -> void:
	for e in enemies:
		var box: Control = e["ui"]
		var click: Button = e["click"]
		if not e["alive"]:
			box.visible = false
			click.visible = false
			continue
		var top := 72.0 if not e["big"] else 104.0
		box.reset_size()
		box.position = (e["node"].position + Vector2(-box.size.x / 2.0, -top - 16)).round()
		click.position = e["node"].position + Vector2(-click.size.x / 2.0, -click.size.y)
		var nm: String = e["name"]
		if Game.has("insane") or Game.has("hallu"):
			var glitch: Array = ["???", "IA MELIHATMU", "kamu", "LARI", "……"] if Loc.lang == "id" else ["???", "IT SEES YOU", "YOU", "RUN", "..."]
			nm = glitch[int(_anim_t * 2 + e["phase"] * 5) % glitch.size()]
		e["ui_name"].text = nm
		e["ui_bar"].max_value = e["max_hp"]
		e["ui_bar"].value = e["hp"]


func _refresh_enemy_status(e: Dictionary) -> void:
	var stb: HBoxContainer = e["ui_st"]
	UI.clear(stb)
	for s in e["st"]:
		var r := UI.icon_rect(DB.status_icon(s))
		r.tooltip_text = "%s\n%s" % [DB.status_name(s, int(e["st"][s].get("stacks", 1))), DB.status_desc(s)]
		stb.add_child(r)
	for p in e["parts"]:
		if p["broken"] and p["brk"] in ["arm", "leg"]:
			var r2 := UI.icon_rect(DB.status_icon("frac_arm" if p["brk"] == "arm" else "frac_leg"))
			stb.add_child(r2)


func _alive() -> Array:
	var a: Array = []
	for e in enemies:
		if e["alive"]:
			a.append(e)
	return a


# =============================================================== frame
func _process(delta: float) -> void:
	_anim_t += delta
	# idle animations (2-frame breathing)
	if _player_pose == "idle":
		player_spr.texture = _tex(G + ("chars/player_idle.png" if fmod(_anim_t, 1.0) < 0.5 else "chars/player_idle2.png"))
	for e in enemies:
		if e["alive"]:
			var f := 0 if fmod(_anim_t + e["phase"], 1.1) < 0.55 else 1
			e["spr"].texture = DB.enemy_tex(e["id"], f)
	_update_overheads()
	if target_arrow.visible:
		target_arrow.position.y = target_arrow.get_meta("base_y", 100.0) + (2 if fmod(_anim_t, 0.5) < 0.25 else 0)
	# screen shake
	if _shake > 0:
		_shake = maxf(0, _shake - delta * 30)
		arena.position = Vector2(rng.randf_range(-_shake, _shake), rng.randf_range(-_shake, _shake)).round()
	else:
		arena.position = Vector2.ZERO
	# QTE
	if qte_active:
		qte_t += delta
		var p := clampf(qte_t / qte_dur, 0.0, 1.0)
		qte_cursor.position.x = round(p * (qte_bar.size.x - 2))
		if Game.has("blind"):
			qte_cursor.visible = fmod(qte_t, 0.24) < 0.12
		if qte_t >= qte_dur:
			_finish_qte(0)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _set_pose(p: String) -> void:
	_player_pose = p
	if p != "idle":
		player_spr.texture = _tex(G + "chars/player_%s.png" % p)


# =============================================================== log / popups
func log_msg(t: String, col: String = "#ece0c8") -> void:
	_log.append("[color=%s]%s[/color]" % [col, t])
	while _log.size() > 30:
		_log.pop_front()
	log_lbl.text = "\n".join(_log)


func popup(text: String, pos: Vector2, col: Color, big: bool = false) -> void:
	if Game.has("hallu") and text.begins_with("-") and rng.randf() < 0.5:
		text = "-%d" % rng.randi_range(1, 999)
	var l := UI.label(text, col, "BigLabel" if big else "")
	if big:
		l.add_theme_color_override("font_color", col)
	l.position = (pos + Vector2(-40, -10)).round()
	l.size = Vector2(80, 14)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - 22, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func vfx(name_: String, pos: Vector2, scale_: int = 2) -> void:
	var s := Sprite2D.new()
	s.texture = _tex(G + "vfx/%s.png" % name_)
	s.hframes = 4
	s.position = pos.round()
	s.scale = Vector2(scale_, scale_)
	fx_layer.add_child(s)
	var tw := create_tween()
	for i in 4:
		tw.tween_callback(func(): s.frame = i)
		tw.tween_interval(0.06)
	tw.tween_callback(s.queue_free)


func flash_sprite(spr: Sprite2D, col: Color = Color(3, 3, 3)) -> void:
	var tw := create_tween()
	tw.tween_property(spr, "modulate", col, 0.04)
	tw.tween_property(spr, "modulate", Color.WHITE, 0.16)


func banner(text: String, col: Color) -> void:
	turn_banner.text = text
	turn_banner.add_theme_color_override("font_color", col)
	turn_banner.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_property(turn_banner, "modulate:a", 0.0, 0.3)


func wait(t: float) -> void:
	await get_tree().create_timer(t).timeout


func _enemy_center(e: Dictionary) -> Vector2:
	return e["node"].position + Vector2(0, -32 if not e["big"] else -48)


func _player_center() -> Vector2:
	return player_node.position + Vector2(0, -30)


# =============================================================== main loop
func _run() -> void:
	await wait(0.6)
	var names: Array = []
	for e in enemies:
		names.append(e["name"])
	log_msg(Loc.t("%s appeared!") % ", ".join(names), "#e85a42")
	if is_boss:
		banner("BOSS!", Color("#c64c98"))
		Sfx.play("boss", 0.0)
		await wait(0.9)
	# phobia check
	var tag: String = DB.PHOBIAS[Game.phobia]["tag"]
	for e in enemies:
		if tag in e["tags"]:
			if Game.add_status("fear", 1):
				log_msg(Loc.t("Your phobia flares up seeing %s! (Fear)") % e["name"], "#c64c98")
				Sfx.play("status_bad")
			break
	# ambush: enemies act first sometimes
	var enemy_first := kind == "ambush" or (not is_boss and rng.randf() < 0.15)
	if enemy_first:
		log_msg(Loc.t("Ambushed! Enemies move first!"), "#ffa848")
		await enemies_phase()
	while not over:
		if _check_end():
			break
		await player_phase()
		if _check_end():
			break
		await enemies_phase()
		if _check_end():
			break
		await end_round()


func _check_end() -> bool:
	if over:
		return true
	if Game.hp <= 0:
		over = true
		_defeat()
		return true
	if fled:
		over = true
		return true
	if _alive().is_empty():
		over = true
		_victory()
		return true
	return false


# =============================================================== player phase
func player_phase() -> void:
	banner(Loc.t("YOUR TURN"), Color("#ffd86a"))
	Game.remove_status("defend")
	var w := Game.eq("weapon")
	if w.has("mind_regen"):
		Game.change_mind(int(w["mind_regen"]))
	if Game.has("stun"):
		Game.remove_status("stun")
		log_msg(Loc.t("You are stunned... turn skipped!"), "#ffa848")
		popup(Loc.t("STUNNED"), _player_center(), Color("#ffe86a"))
		await wait(0.8)
		return
	var fear := Game.stacks("fear")
	if fear > 0 and rng.randf() < 0.1 * fear:
		log_msg(Loc.t("Your body freezes in fear! Cannot move!"), "#c64c98")
		popup(Loc.t("FROZEN"), _player_center(), Color("#c64c98"))
		Sfx.play("status_bad")
		await wait(0.9)
		return
	while true:
		var cmd = await show_menu(Loc.t("What will you do?"), [
			{"key": "attack", "text": Loc.t("Attack"), "icon": DB.icon("atk"), "tip": Loc.t("Attack enemy's body parts with %s.") % DB.item_name(w.get("id", "w_tangan"))},
			{"key": "defend", "text": Loc.t("Defend"), "icon": DB.icon("def"), "tip": Loc.t("Damage -50%, wider parry zone, Mind +5.")},
			{"key": "skill", "text": Loc.t("Skill"), "icon": DB.icon("mind"), "disabled": Game.has("silence"), "tip": Loc.t("Mute! Cannot use skills.") if Game.has("silence") else Loc.t("Special abilities that cost Mind.")},
			{"key": "item", "text": Loc.t("Item"), "icon": DB.item_icon("kantong"), "tip": Loc.t("Use items from your bag.")},
			{"key": "flee", "text": Loc.t("Flee"), "icon": DB.icon("agi"), "disabled": is_boss or Game.has("frac_leg"),
				"tip": Loc.t("Boss cannot be escaped.") if is_boss else (Loc.t("Legs broken! Cannot flee.") if Game.has("frac_leg") else Loc.t("Flee chance: %d%%") % _flee_chance())},
		], false)
		match cmd:
			"attack":
				var t = await pick_target()
				if t == null:
					continue
				var p := await pick_part(t)
				if p < 0:
					continue
				await do_attack(t, p)
				return
			"defend":
				Game.add_status("defend", 1, 1)
				Game.change_mind(5)
				_set_pose("defend")
				log_msg(Loc.t("You brace yourself to defend."), "#6c92ea")
				popup(Loc.t("DEFEND"), _player_center(), Color("#6c92ea"))
				Sfx.play("guard")
				await wait(0.6)
				return
			"skill":
				if await skill_menu():
					return

			"item":
				if await item_menu():
					return
			"flee":
				await try_flee(false)
				return


func show_menu(title: String, opts: Array, can_back: bool = true):
	menu_title.text = title
	UI.clear(menu_box)
	var first: Button = null
	for o in opts:
		var b := Button.new()
		b.theme_type_variation = "ListButton"
		b.text = o["text"]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.disabled = o.get("disabled", false)
		if o.has("icon") and o["icon"] != null:
			b.icon = o["icon"]
		var key = o["key"]
		var tip: String = o.get("tip", "")
		b.pressed.connect(func(): Sfx.play("select", 0.03, -4); menu_pick.emit(key))
		b.focus_entered.connect(func(): hint_lbl.text = tip; _on_menu_focus(key))
		b.mouse_entered.connect(func(): if not b.disabled: b.grab_focus())
		menu_box.add_child(b)
		if first == null and not b.disabled:
			first = b
	if can_back:
		var bb := Button.new()
		bb.theme_type_variation = "ListButton"
		bb.text = "← " + Loc.t("Back")
		bb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		bb.pressed.connect(func(): Sfx.play("cancel"); menu_pick.emit(null))
		bb.focus_entered.connect(func(): hint_lbl.text = "[Esc] " + Loc.t("Back"); _on_menu_focus(null))
		menu_box.add_child(bb)
	await get_tree().process_frame
	if first:
		first.grab_focus()
	_menu_open = true
	var v = await menu_pick
	_menu_open = false
	target_arrow.visible = false
	UI.clear(menu_box)
	menu_title.text = ""
	hint_lbl.text = ""
	if typeof(v) == TYPE_STRING and v == "__relang":
		v = null
	return v


func _on_menu_focus(key) -> void:
	if typeof(key) == TYPE_DICTIONARY and key.has("node"):
		_point_at(key)
	elif typeof(key) == TYPE_ARRAY and key.size() == 2 and typeof(key[0]) == TYPE_DICTIONARY:
		_point_at(key[0])


func _point_at(e: Dictionary) -> void:
	target_arrow.visible = true
	var top := 76.0 if not e["big"] else 108.0
	target_arrow.position = (e["node"].position + Vector2(0, -top - 22)).round()
	target_arrow.set_meta("base_y", target_arrow.position.y)


var _targeting := false


func _on_enemy_clicked(e: Dictionary) -> void:
	if _targeting and e["alive"]:
		menu_pick.emit(e)


func _input(event: InputEvent) -> void:
	if not qte_active:
		return
	var hit := false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER, KEY_Z, KEY_X]:
		hit = true
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hit = true
	elif event is InputEventScreenTouch and event.pressed:
		hit = true
	if hit:
		get_viewport().set_input_as_handled()
		_judge_qte()


func _unhandled_input(event: InputEvent) -> void:
	if qte_active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_O:
			get_viewport().set_input_as_handled()
			_open_settings()
			return
		elif event.keycode == KEY_G:
			get_viewport().set_input_as_handled()
			_open_guide("combat")
			return
		elif event.keycode == KEY_C:
			get_viewport().set_input_as_handled()
			_show_conditions()
			return
		elif event.keycode == KEY_ESCAPE or event.keycode == KEY_BACKSPACE:
			if menu_box.get_child_count() > 0:
				var last := menu_box.get_child(menu_box.get_child_count() - 1)
				if last is Button and (last as Button).text.begins_with("←"):
					get_viewport().set_input_as_handled()
					(last as Button).emit_signal("pressed")
					return
			get_viewport().set_input_as_handled()
			_open_pause_menu()
			return
		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var i: int = event.keycode - KEY_1
			if i < menu_box.get_child_count():
				var b := menu_box.get_child(i)
				if b is Button and not (b as Button).disabled:
					get_viewport().set_input_as_handled()
					(b as Button).emit_signal("pressed")
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if menu_box.get_child_count() > 0:
			var last2 := menu_box.get_child(menu_box.get_child_count() - 1)
			if last2 is Button and (last2 as Button).text.begins_with("←"):
				(last2 as Button).emit_signal("pressed")


func pick_target():
	var opts: Array = []
	for e in _alive():
		opts.append({"key": e, "text": "%s  %d/%d" % [e["name"], e["hp"], e["max_hp"]], "tip": Loc.t("Click enemy or choose from list.")})
	if opts.size() == 1 and false:
		return opts[0]["key"]
	_set_targeting(true)
	var r = await show_menu(Loc.t("Select target:"), opts)
	_set_targeting(false)
	return r


func _set_targeting(on: bool) -> void:
	_targeting = on
	for e in enemies:
		e["click"].mouse_filter = Control.MOUSE_FILTER_STOP if (on and e["alive"]) else Control.MOUSE_FILTER_IGNORE


func _hit_chance(e: Dictionary, part: Dictionary, bonus: int = 0) -> int:
	var h := Game.accuracy() + int(part["hit"]) + bonus
	if not e["leg_broken"]:
		h -= int(e["agi"]) * 2
	if e["st"].has("stun"):
		h += 25
	return clampi(h, 5, 98)


func pick_part(e: Dictionary) -> int:
	var opts: Array = []
	var hide := Game.has("blind") or Game.has("hallu")
	for i in e["parts"].size():
		var p: Dictionary = e["parts"][i]
		var hc := _hit_chance(e, p)
		var eff: String = Loc.t(DB.PART_EFFECT.get(p["brk"], "main"))
		var txt := "%s  %s%%" % [DB.part_name(p), "??" if hide else str(hc)]
		if p["broken"]:
			txt += " " + Loc.t("(broken)")
		else:
			txt += "  %d/%d" % [p["hp"], p["max_hp"]]
		opts.append({"key": i, "text": txt, "tip": eff})
	_point_at(e)
	var r = await show_menu(Loc.t("Body parts of %s:") % e["name"], opts)
	if r == null:
		return -1
	return int(r)


# =============================================================== attacking
func do_attack(e: Dictionary, part_i: int, mult: float = 1.0, hit_bonus: int = 0, force_crit: bool = false, lunge: bool = true) -> void:
	# insanity: you might strike the wrong target... or yourself
	if Game.has("insane") and rng.randf() < 0.18:
		var others := _alive()
		if rng.randf() < 0.35 or others.size() <= 1:
			var self_dmg := maxi(1, int(Game.atk() * 0.5))
			log_msg(Loc.t("In your madness, you strike yourself! (-%d)") % self_dmg, "#9c8cff")
			Game.change_hp(-self_dmg)
			_set_pose("hurt")
			popup("-%d" % self_dmg, _player_center(), Color("#9c8cff"))
			Sfx.play("hit")
			await wait(0.6)
			_set_pose("idle")
			return
		e = others[rng.randi() % others.size()]
		part_i = rng.randi() % e["parts"].size()
		log_msg(Loc.t("Hallucination! Your attack turns toward %s!") % e["name"], "#9c8cff")
	var part: Dictionary = e["parts"][part_i]
	var home := player_node.position
	if lunge:
		_set_pose("attack")
		weapon_spr.texture = DB.item_icon(Game.equip.get("weapon", "w_tangan"))
		weapon_spr.visible = Game.equip.get("weapon", "w_tangan") != "w_tangan"
		var tw := create_tween()
		tw.tween_property(player_node, "position", e["node"].position + Vector2(-70, 0), 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		await tw.finished
	await _strike(e, part, mult, hit_bonus, force_crit)
	if lunge:
		await wait(0.12)
		var tw2 := create_tween()
		tw2.tween_property(player_node, "position", home, 0.16).set_trans(Tween.TRANS_QUAD)
		await tw2.finished
		weapon_spr.visible = false
		_set_pose("idle")


func _strike(e: Dictionary, part: Dictionary, mult: float, hit_bonus: int, force_crit: bool) -> void:
	if not e["alive"]:
		return
	var hc := _hit_chance(e, part, hit_bonus)
	var c := _enemy_center(e)
	if rng.randi() % 100 >= hc:
		popup(Loc.t("MISSED"), c, Color("#a89ab8"))
		log_msg(Loc.t("Your attack on %s %s missed!") % [DB.part_name(part).to_lower(), e["name"]], "#a89ab8")
		Sfx.play("miss")
		return
	var w := Game.eq("weapon")
	var dmg := float(Game.atk()) * mult * rng.randf_range(0.85, 1.15) - float(e["def"]) * 0.6
	if e["st"].has("def_down"):
		dmg += float(e["def"]) * 0.3
	dmg *= 1.0 - 0.12 * Game.stacks("fear")
	var crit := force_crit or rng.randi() % 100 < Game.crit_chance()
	if Game.weak_mark.get("name", "") == e["name"] and Game.weak_mark.get("ref") == e:
		crit = true
		Game.weak_mark = {}
	if crit:
		dmg *= 1.75
	var tags: Array = e["tags"]
	if w.get("dtype", "") == "occult" and "dark" in tags:
		dmg *= 0.8
	var d := maxi(1, int(dmg))
	vfx("slash", c)
	vfx("blood", c + Vector2(0, 6))
	flash_sprite(e["spr"])
	shake(6.0 if crit else 3.0)
	Sfx.play("crit" if crit else ("hit_heavy" if d > 15 else "hit"))
	popup(("%s -%d" % [Loc.t("CRITICAL!"), d] if crit else "-%d" % d), c, Color("#ffd86a") if crit else Color("#ff6a5a"), crit)
	log_msg("%s%s: %s " % [Loc.t("CRITICAL! ") if crit else "", DB.part_name(part), e["name"]] + (Loc.t("took %d dmg.") % d), "#ffd86a" if crit else "#ece0c8")

	# damage the part and the main body
	if not part["broken"]:
		part["hp"] = maxi(0, int(part["hp"]) - d)
	e["hp"] = maxi(0, int(e["hp"]) - int(ceil(d * float(part["to_main"]))))
	# lifesteal
	var ls := 0.0
	for slot in ["accessory"]:
		ls += float(Game.eq(slot).get("lifesteal", 0.0))
	if ls > 0:
		Game.heal(maxi(1, int(d * ls)))
	# weapon procs
	for pr in w.get("proc", {}):
		if rng.randf() < float(w["proc"][pr]):
			match pr:
				"bleed":
					_enemy_status(e, "bleed", 1, 3)
				"burn":
					_enemy_status(e, "burn", 1, 3)
				"stun":
					_enemy_status(e, "stun", 1, 1)
				"break":
					if part["brk"] in ["arm", "leg"] and not part["broken"]:
						part["hp"] = 0
						log_msg(Loc.t("CRACK! Bone broken!"), "#ffa848")
					else:
						_enemy_status(e, "stun", 1, 1)
	# part break
	if part["hp"] <= 0 and not part["broken"] and part["brk"] != "main":
		part["broken"] = true
		await _break_part(e, part)
	if e["alive"] and e["hp"] <= 0:
		await _kill(e)
	elif e["alive"]:
		await _maybe_split(e, d)
	_refresh_enemy_status(e)


func _break_part(e: Dictionary, part: Dictionary) -> void:
	var c := _enemy_center(e)
	match part["brk"]:
		"kill":
			log_msg(Loc.t("%s %s destroyed!") % [DB.part_name(part), e["name"]], "#e85a42")
			popup(Loc.t("FATAL!"), c + Vector2(0, -14), Color("#e85a42"), true)
			Sfx.play("crit")
			shake(8)
			e["hp"] = 0
		"arm":
			e["arm_broken"] = true
			log_msg(Loc.t("%s's arm broken! Attack weakened.") % e["name"], "#ffa848")
			popup(Loc.t("ARM BROKEN"), c + Vector2(0, -14), Color("#ffa848"))
		"leg":
			e["leg_broken"] = true
			log_msg(Loc.t("%s's leg broken! Cannot dodge.") % e["name"], "#ffa848")
			popup(Loc.t("LEG BROKEN"), c + Vector2(0, -14), Color("#ffa848"))
			_enemy_status(e, "stun", 1, 1)
		"blind":
			e["blinded"] = true
			_enemy_status(e, "blind", 1, 99)
			log_msg(Loc.t("%s's eye ruptured! It is blinded.") % e["name"], "#ffa848")
		"free":
			log_msg(Loc.t("Shroud knot severed... the spirit smiles and vanishes in peace."), "#7ec45c")
			popup(Loc.t("FREED"), c, Color("#7ec45c"), true)
			Game.change_mind(12)
			e["hp"] = 0
		"stun":
			_enemy_status(e, "stun", 1, 1)
			part["broken"] = false
			part["hp"] = part["max_hp"]
			log_msg(Loc.t("%s stumbles! (Stunned)") % e["name"], "#ffa848")
	await wait(0.25)


func _maybe_split(e: Dictionary, dmg: int) -> void:
	var d: Dictionary = DB.ENEMIES[e["id"]]
	if d.has("split") and not e["split_done"] and e["hp"] < e["max_hp"] * 0.5 and _alive().size() < 4:
		e["split_done"] = true
		var ne := _add_enemy(d["split"])
		ne["max_hp"] = int(ne["max_hp"] * 0.5)
		ne["hp"] = ne["max_hp"]
		ne["exp"] = int(ne["exp"] * 0.4)
		ne["split_done"] = true
		log_msg(Loc.t("%s DIVIDES ITSELF!") % e["name"], "#e85a42")
		Sfx.play("growl")
		_layout_enemies(true)
		await wait(0.4)


func _kill(e: Dictionary) -> void:
	e["alive"] = false
	Game.kills += 1
	var spr: Sprite2D = e["spr"]
	log_msg(Loc.t("%s was defeated!") % e["name"], "#7ec45c")
	Sfx.play("death" if e["boss"] else "hit_heavy", 0.1, -4)
	var tw := create_tween()
	tw.tween_property(spr, "modulate", Color(3, 0.4, 0.4, 1), 0.08)
	tw.tween_property(spr, "modulate", Color(1, 1, 1, 0), 0.5)
	tw.parallel().tween_property(e["node"], "scale", Vector2(2, 0.4), 0.5)
	await tw.finished
	e["node"].visible = false
	if Game.weak_mark.get("ref") == e:
		Game.weak_mark = {}


func _enemy_status(e: Dictionary, id: String, n: int, turns: int) -> void:
	if e["boss"] and id == "stun" and rng.randf() < 0.5:
		return
	var s: Dictionary = e["st"].get(id, {"stacks": 0, "turns": 0})
	s["stacks"] = mini(int(s["stacks"]) + n, int(DB.STATUS[id]["max"]))
	s["turns"] = maxi(int(s["turns"]), turns)
	e["st"][id] = s
	popup(DB.status_name(id).to_upper(), _enemy_center(e) + Vector2(0, -16), Color("#ffa848"))
	_refresh_enemy_status(e)
	if id == "bleed" and Game.phobia == "darah" and rng.randf() < 0.25:
		Game.add_status("fear", 1)
		log_msg(Loc.t("Blood... so much blood... (Hemophobia)"), "#c64c98")



# =============================================================== skills & items
func skill_menu() -> bool:
	var opts: Array = []
	for id in Game.skills:
		var s: Dictionary = DB.SKILLS[id]
		opts.append({"key": id, "text": "%s  (%d)" % [DB.skill_name(id), int(s["mind"])], "icon": DB.icon("mind"),
			"disabled": Game.mind < int(s["mind"]), "tip": DB.skill_desc(id)})
	var id = await show_menu(Loc.t("Skill (Mind %d):") % Game.mind, opts)
	if id == null:
		return false
	var sk: Dictionary = DB.SKILLS[id]
	var target = null
	if sk["target"] == "enemy":
		target = await pick_target()
		if target == null:
			return false
	Game.change_mind(-int(sk["mind"]))
	var boost := 1.0 + float(Game.eq("weapon").get("skill_boost", 0.0))
	log_msg(Loc.t("You used %s!") % DB.skill_name(id), "#9c8cff")
	match id:
		"beruntun":
			_set_pose("attack")
			var home := player_node.position
			var tw := create_tween()
			tw.tween_property(player_node, "position", target["node"].position + Vector2(-66, 0), 0.14)
			await tw.finished
			for i in 3:
				if not target["alive"]:
					break
				await _strike(target, target["parts"][rng.randi() % target["parts"].size()], 0.6 * boost, 10, false)
				await wait(0.12)
			var tw2 := create_tween()
			tw2.tween_property(player_node, "position", home, 0.16)
			await tw2.finished
			_set_pose("idle")
		"napas":
			Game.change_mind(20)
			Game.reduce_status("fear", 1)
			Game.add_status("focus", 1, 2)
			vfx("heal", _player_center())
			Sfx.play("heal")
			popup(Loc.t("FOCUS"), _player_center(), Color("#9c8cff"))
			await wait(0.6)
		"pasir":
			vfx("poison", _enemy_center(target))
			Sfx.play("miss")
			_enemy_status(target, "blind", 1, 2)
			log_msg(Loc.t("%s got sand in their eyes!") % target["name"], "#ffa848")
			await wait(0.5)
		"p3k":
			Game.remove_status("bleed")
			var h := Game.heal(int(22 * boost))
			vfx("heal", _player_center())
			Sfx.play("heal")
			popup("+%d" % h if h > 0 else "TRAUMA!", _player_center(), Color("#7ec45c") if h > 0 else Color("#e85a42"))
			await wait(0.6)
		"teriak":
			Sfx.play("growl")
			shake(5)
			for e in _alive():
				_enemy_status(e, "fear", 1, 3)
			Game.add_status("adren", 1, 3)
			popup(Loc.t("ADRENALINE"), _player_center(), Color("#ffd86a"))
			await wait(0.7)
		"api":
			Game.change_hp(-6)
			Sfx.play("fire")
			shake(7)
			for e in _alive():
				vfx("fire", e["node"].position + Vector2(0, -20))
			await wait(0.25)
			for e in _alive():
				var d := maxi(1, int((14 + Game.atk() * 0.8) * boost * rng.randf_range(0.9, 1.1)) - int(e["def"]))
				e["hp"] = maxi(0, int(e["hp"]) - d)
				popup("-%d" % d, _enemy_center(e), Color("#ffa848"))
				flash_sprite(e["spr"], Color(3, 1.5, 0.5))
				_enemy_status(e, "burn", 1, 3)
				if e["hp"] <= 0:
					await _kill(e)
			Game.add_status("bloodlust", 1)
			log_msg(Loc.t("Occult fire burns! Filled with Bloodlust."), "#ffa848")
			await wait(0.4)
		"analisis":
			Game.weak_mark = {"name": target["name"], "ref": target}
			var weakest := ""
			var best := 999
			for p in target["parts"]:
				if not p["broken"] and int(p["hp"]) < best and p["brk"] != "main":
					best = int(p["hp"])
					weakest = DB.part_name(p)
			log_msg(Loc.t("Analysis: weak spot of %s is %s. Next hit guaranteed CRIT!") % [target["name"], DB.part_name({"name": weakest}).to_lower()], "#62c8b8")
			popup(Loc.t("ANALYZED"), _enemy_center(target), Color("#62c8b8"))
			Sfx.play("magic")
			await wait(0.6)
		"fatal":
			var head := 0
			for i in target["parts"].size():
				if target["parts"][i]["id"] in ["kepala", "inti", "mata"]:
					head = i
					break
			await do_attack(target, head, 2.5 * boost, 30)
	return true


func item_menu() -> bool:
	var opts: Array = []
	for id in Game.inventory:
		var it := DB.item(id)
		if it.get("kind", "") != "consumable" or it.get("use", "both") == "board":
			continue
		var dis := false
		var tip: String = DB.item_desc(id)
		if id == "bom_asap" and is_boss:
			dis = true
			tip = Loc.t("Boss cannot be escaped.")
		opts.append({"key": id, "text": "%s x%d" % [DB.item_name(id), Game.count(id)], "icon": DB.item_icon(id), "disabled": dis, "tip": tip})
	if opts.is_empty():
		opts.append({"key": "_none", "text": Loc.t("(empty)"), "disabled": true})
	var id = await show_menu(Loc.t("Item:"), opts)
	if id == null or id == "_none":
		return false
	var it := DB.item(id)
	var tgt: String = it.get("target", "self")
	match tgt:
		"enemy":
			var target = await pick_target()
			if target == null:
				return false
			Game.remove_item(id)
			await _throw_item(id, it, [target])
		"all":
			Game.remove_item(id)
			await _throw_item(id, it, _alive())
		_:
			if id == "bom_asap":
				Game.remove_item(id)
				await try_flee(true)
				return true
			var msgs := Game.use_consumable(id)
			log_msg("%s: %s" % [DB.item_name(id), ", ".join(msgs) if not msgs.is_empty() else Loc.t("no effect")], "#7ec45c")
			vfx("heal", _player_center())
			Sfx.play("heal")
			if it.has("heal"):
				popup("+%d" % int(it["heal"]), _player_center(), Color("#7ec45c"))
			await wait(0.6)
	return true


func _throw_item(id: String, it: Dictionary, targets: Array) -> void:
	log_msg(Loc.t("You threw %s!") % DB.item_name(id), "#ece0c8")

	for e in targets:
		var s := Sprite2D.new()
		s.texture = DB.item_icon(id)
		s.scale = Vector2(2, 2)
		s.position = _player_center()
		fx_layer.add_child(s)
		var tw := create_tween()
		tw.tween_property(s, "position", _enemy_center(e), 0.22)
		await tw.finished
		s.queue_free()
		var d := int(it.get("dmg", 10))
		if it.has("vs_tag") and not it["vs_tag"] in e["tags"]:
			d = int(d * 0.3)
		e["hp"] = maxi(0, int(e["hp"]) - d)
		popup("-%d" % d, _enemy_center(e), Color("#ff6a5a"))
		flash_sprite(e["spr"])
		vfx("fire" if id == "molotov" else "spark", _enemy_center(e))
		Sfx.play("fire" if id == "molotov" else "hit")
		for st in it.get("inflict", {}):
			if rng.randf() < float(it["inflict"][st]):
				_enemy_status(e, st, 1, 3 if st != "stun" else 1)
		if e["hp"] <= 0:
			await _kill(e)
	await wait(0.3)


func _flee_chance() -> int:
	var avg := 0.0
	var n := 0
	for e in _alive():
		if not e["leg_broken"]:
			avg += e["agi"]
			n += 1
	if n > 0:
		avg /= n
	return clampi(50 + int((Game.agi() - avg) * 6), 10, 95)


func try_flee(guaranteed: bool) -> void:
	var ch := 100 if guaranteed else _flee_chance()
	if rng.randi() % 100 < ch:
		log_msg(Loc.t("You successfully escaped!"), "#7ec45c")
		Sfx.play("step")
		var tw := create_tween()
		tw.tween_property(player_node, "position:x", -60.0, 0.4)
		await tw.finished
		fled = true
		_finish({"result": "flee"})
	else:
		log_msg(Loc.t("Failed to escape! They block your path!"), "#e85a42")
		popup(Loc.t("FAILED"), _player_center(), Color("#e85a42"))
		Sfx.play("error")
		await wait(0.6)


# =============================================================== enemy phase
func enemies_phase() -> void:
	banner(Loc.t("ENEMY TURN"), Color("#e85a42"))
	await wait(0.4)
	for e in _alive().duplicate():
		if over or Game.hp <= 0:
			return
		if not e["alive"]:
			continue
		await enemy_act(e)
		if Game.hp <= 0:
			return
		await wait(0.2)


func enemy_act(e: Dictionary) -> void:
	var c := _enemy_center(e)
	if e["st"].has("stun"):
		e["st"].erase("stun")
		_refresh_enemy_status(e)
		log_msg(Loc.t("%s is still stunned.") % e["name"], "#a89ab8")
		popup(Loc.t("STUNNED"), c, Color("#ffe86a"))
		await wait(0.5)
		return
	var fear := int(e["st"].get("fear", {}).get("stacks", 0))
	if fear > 0 and rng.randf() < 0.2 * fear:
		log_msg(Loc.t("%s trembles in fear and cannot attack.") % e["name"], "#c64c98")
		popup(Loc.t("AFRAID"), c, Color("#c64c98"))
		await wait(0.5)
		return
	var d: Dictionary = DB.ENEMIES[e["id"]]
	# thieves run away with your money
	if d.has("flee_hp") and e["hp"] < e["max_hp"] * float(d["flee_hp"]) and not e["leg_broken"] and (e["stolen_gold"] > 0 or rng.randf() < 0.4):
		log_msg(Loc.t("%s fled carrying %d of your coins!") % [e["name"], e["stolen_gold"]] if e["stolen_gold"] > 0 else Loc.t("%s fled!") % e["name"], "#ffa848")
		e["alive"] = false
		e["fled"] = true
		var tw := create_tween()
		tw.tween_property(e["node"], "position:x", 720.0, 0.4)
		await tw.finished
		e["node"].visible = false
		return
	var sk := _choose_skill(e)
	log_msg("%s %s" % [e["name"], Loc.t(sk["msg"])], "#e8a0a0")
	_show_skill_name(e, Loc.t(sk["name"]))
	var home: Vector2 = e["node"].position
	match sk["kind"]:
		"hit", "multi":
			var tw2 := create_tween()
			tw2.tween_property(e["node"], "position", home + Vector2(-40, 0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			await tw2.finished
			await _enemy_attack(e, sk)
			var tw3 := create_tween()
			tw3.tween_property(e["node"], "position", e.get("home", home), 0.2)
			await tw3.finished
		"status", "aoe_status":
			Sfx.play("whisper" if sk["status"] in ["fear", "curse"] else "status_bad")
			vfx("dark", _player_center())
			await wait(0.35)
			if rng.randf() < float(sk.get("chance", 0.5)):
				await _inflict(sk["status"])
			else:
				log_msg(Loc.t("You resisted the effect."), "#7ec45c")
		"mind":
			Sfx.play("whisper")
			vfx("dark", _player_center())
			Transition.flash(Color(0.3, 0, 0.4), 0.3)
			var md := int(float(sk["power"]) * (1.0 + 0.12 * Game.stacks("fear")) * rng.randf_range(0.85, 1.15))
			if Game.has("blessed"):
				md = int(md * 0.5)
			Game.change_mind(-md)
			popup("MIND -%d" % md, _player_center(), Color("#9c8cff"))
			await wait(0.5)
		"steal_gold":
			var tw4 := create_tween()
			tw4.tween_property(e["node"], "position", home + Vector2(-60, 0), 0.15)
			await tw4.finished
			var amt := mini(Game.gold, rng.randi_range(8, 20) * Game.stage)
			if amt > 0 and rng.randi() % 100 >= Game.agi() * 4:
				Game.change_gold(-amt)
				e["stolen_gold"] += amt
				Sfx.play("steal")
				popup(Loc.t("-%d COINS") % amt, _player_center(), Color("#ffe86a"))
				log_msg(Loc.t("%d coins stolen! Defeat them to get it back.") % amt, "#ffa848")
			else:
				popup(Loc.t("FAILED"), _player_center(), Color("#7ec45c"))
				log_msg(Loc.t("You swatted their hand away!"), "#7ec45c")
			var tw5 := create_tween()
			tw5.tween_property(e["node"], "position", e.get("home", home), 0.15)
			await tw5.finished
		"steal_item":
			var pool: Array = []
			for id in Game.inventory:
				if DB.item(id).get("kind", "") in ["consumable", "material"]:
					pool.append(id)
			if pool.is_empty() or e["arm_broken"]:
				log_msg(Loc.t("...but there was nothing left to take."), "#a89ab8")
			else:
				var it: String = pool[rng.randi() % pool.size()]
				Game.remove_item(it)
				e["stolen_items"].append(it)
				Sfx.play("steal")
				popup("-%s" % DB.item_name(it), _player_center(), Color("#ffa848"))
				log_msg(Loc.t("%s was snatched!") % DB.item_name(it), "#ffa848")
			await wait(0.4)
		"summon":
			if _alive().size() < 4:
				var ne := _add_enemy(sk["summon"])
				ne["exp"] = int(ne["exp"] * 0.5)
				Sfx.play("growl")
				_layout_enemies(true)
				log_msg(Loc.t("%s joined the fight!") % ne["name"], "#e85a42")
			await wait(0.5)

		"heal":
			var h := int(e["max_hp"] * float(sk["power"]))
			e["hp"] = mini(e["max_hp"], e["hp"] + h)
			vfx("heal", c)
			popup("+%d" % h, c, Color("#7ec45c"))
			Sfx.play("heal")
			await wait(0.5)


func _show_skill_name(e: Dictionary, n: String) -> void:
	var l := UI.label(n, Color("#ffd0d0"))
	var top := 76.0 if not e["big"] else 108.0
	l.position = (e["node"].position + Vector2(-60, -top - 30)).round()
	l.size = Vector2(120, 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui.add_child(l)
	var tw := create_tween()
	tw.tween_interval(0.9)
	tw.tween_property(l, "modulate:a", 0.0, 0.3)
	tw.tween_callback(l.queue_free)


func _choose_skill(e: Dictionary) -> Dictionary:
	var d: Dictionary = DB.ENEMIES[e["id"]]
	var pool: Array = []
	var total := 0
	for s in d["skills"]:
		var w := int(s["w"])
		match s["kind"]:
			"heal":
				if e["hp"] > e["max_hp"] * 0.6:
					w = 0
			"summon":
				if _alive().size() >= 4:
					w = 0
			"steal_item":
				if e["arm_broken"]:
					w = 0
			"steal_gold":
				if Game.gold <= 0:
					w = 0
		if w > 0:
			pool.append([s, w])
			total += w
	if total == 0:
		return d["skills"][0]
	var r := rng.randi() % total
	for p in pool:
		r -= int(p[1])
		if r < 0:
			return p[0]
	return pool[0][0]


func _enemy_attack(e: Dictionary, sk: Dictionary) -> void:
	var hits := int(sk.get("hits", 1))
	# dodge (agility)
	var dodge := Game.agi() * 2
	if e["leg_broken"]:
		dodge += 10
	if rng.randi() % 100 < dodge:
		log_msg(Loc.t("You dodged nimbly!"), "#7ec45c")
		popup(Loc.t("DODGE"), _player_center(), Color("#7ec45c"))
		Sfx.play("miss")
		await wait(0.3)
		return
	# blinded enemies often miss
	if e["st"].has("blind") and rng.randf() < 0.45:
		log_msg(Loc.t("%s attacks wildly... missed!") % e["name"], "#a89ab8")
		popup(Loc.t("MISSED"), _player_center(), Color("#a89ab8"))
		Sfx.play("miss")
		await wait(0.3)
		return
	var grade := await run_qte(e)
	for i in hits:
		if Game.hp <= 0:
			return
		var dmg := float(e["atk"]) * float(sk.get("power", 1.0)) * rng.randf_range(0.85, 1.15)
		if e["arm_broken"]:
			dmg *= 0.6
		var ef := int(e["st"].get("fear", {}).get("stacks", 0))
		dmg *= 1.0 - 0.1 * ef
		dmg -= Game.defense() * 0.5
		dmg *= 1.0 + 0.12 * Game.stacks("fear")
		if Game.has("defend"):
			dmg *= 0.5
		var pc := _player_center()
		match grade:
			2:
				if i == 0:
					log_msg(Loc.t("PERFECT PARRY! Attack deflected with a counter!"), "#ffd86a")
					popup("PERFECT!", pc + Vector2(0, -12), Color("#ffd86a"), true)
					vfx("spark", pc + Vector2(20, 0))
					Sfx.play("parry", 0.0)
					shake(4)
					_set_pose("defend")
					Game.change_mind(4)
					await wait(0.25)
					var torso := 0
					for k in e["parts"].size():
						if e["parts"][k]["brk"] == "main":
							torso = k
					await _strike(e, e["parts"][torso], 0.7 if not Game.has("defend") else 0.9, 40, false)
					_set_pose("idle")
				continue
			1:
				dmg *= 0.3
		var di := maxi(1, int(dmg))
		Game.change_hp(-di)
		if Game.has("bloodlust"):
			Game.remove_status("bloodlust")
		var guard := grade == 1
		_set_pose("defend" if guard else "hurt")
		flash_sprite(player_spr, Color(3, 0.5, 0.5))
		vfx("spark" if guard else "blood", pc)
		shake(3 if guard else 7)
		Sfx.play("guard" if guard else "hit_heavy")
		popup((Loc.t("GUARD -%d") % di if guard else "-%d" % di), pc, Color("#ffa848") if guard else Color("#ff4a3a"), not guard)
		if i == 0:
			log_msg((Loc.t("Guarded: %d damage.") if guard else Loc.t("Hit: %d damage.")) % di + ("" if hits == 1 else " (x%d)" % hits), "#ffa848" if guard else "#ff6a5a")
		# status infliction
		if sk.has("status"):
			var ch := float(sk.get("chance", 0.3)) * (0.35 if guard else 1.0)
			if rng.randf() < ch:
				await _inflict(sk["status"])
		await wait(0.22)
	_set_pose("idle")


func _inflict(st: String) -> void:
	var turns := -1
	var steps := -1
	match st:
		"burn", "def_down", "silence", "hallu":
			turns = 3
		"stun":
			turns = 1
		"blind":
			turns = 3
			steps = 8
	if Game.add_status(st, 1, turns, steps):
		var nm := DB.status_name(st, Game.stacks(st))
		log_msg(Loc.t("You were inflicted with %s!") % nm, "#e85a42")
		popup(nm.to_upper(), _player_center() + Vector2(0, -14), Color("#e85a42"))
		Sfx.play("status_bad")
		await wait(0.3)



# =============================================================== QTE
func run_qte(e: Dictionary) -> int:
	var w := 0.26
	var pw := 0.07
	if Game.has("defend"):
		w *= 1.8
		pw *= 1.9
	w *= 1.0 - 0.12 * Game.stacks("fear")
	pw *= 1.0 - 0.15 * Game.stacks("fear")
	if Game.has("focus"):
		pw *= 1.4
	var center := rng.randf_range(0.42, 0.78)
	qte_zone = Vector4(center - w / 2, center + w / 2, center - pw / 2, center + pw / 2)
	qte_dur = maxf(0.55, 0.95 - 0.08 * (Game.stage - 1) - (0.05 if e["boss"] else 0.0))
	var bw := qte_bar.size.x
	qte_guard.position = Vector2(round(qte_zone.x * bw), 0)
	qte_guard.size = Vector2(round((qte_zone.y - qte_zone.x) * bw), 10)
	qte_perfect.position = Vector2(round(qte_zone.z * bw), 0)
	qte_perfect.size = Vector2(maxf(2, round((qte_zone.w - qte_zone.z) * bw)), 10)
	qte_cursor.position.x = 0
	qte_cursor.visible = true
	qte_label.text = Loc.t("PARRY! [SPACE]/click in gold zone") if not Game.has("defend") else Loc.t("DEFENDING: wider zone! [SPACE]")
	qte_panel.visible = true
	qte_t = 0.0
	qte_active = true
	var g: int = await qte_done
	return g


func _judge_qte() -> void:
	var p := clampf(qte_t / qte_dur, 0.0, 1.0)
	var g := 0
	if p >= qte_zone.z and p <= qte_zone.w:
		g = 2
	elif p >= qte_zone.x and p <= qte_zone.y:
		g = 1
	_finish_qte(g)


func _finish_qte(g: int) -> void:
	if not qte_active:
		return
	qte_active = false
	qte_label.text = [Loc.t("FAILED!"), Loc.t("GUARDED!"), Loc.t("PERFECT!")][g]
	var tw := create_tween()
	tw.tween_interval(0.25)
	tw.tween_callback(func(): qte_panel.visible = false)
	qte_done.emit(g)


# =============================================================== end of round ticks
func end_round() -> void:
	# player statuses
	var pc := _player_center()
	if Game.has("bleed"):
		var d := 3 * Game.stacks("bleed")
		Game.change_hp(-d)
		popup("-%d" % d, pc, Color("#c8323a"))
		log_msg(Loc.t("Bleeding: -%d HP.") % d, "#c8323a")
	if Game.has("burn"):
		Game.change_hp(-5)
		popup("-5", pc, Color("#ffa848"))
		vfx("fire", player_node.position + Vector2(0, -20))
	if Game.has("poison"):
		var s: Dictionary = Game.statuses["poison"]
		s["count"] = int(s["count"]) + 1
		var pd := 3 + int(s["count"])
		Game.change_hp(-pd)
		popup("-%d" % pd, pc, Color("#5ca83c"))
	if Game.has("toxic"):
		var s2: Dictionary = Game.statuses["toxic"]
		s2["count"] = int(s2["count"]) + 1
		var td := 6 + 2 * int(s2["count"])
		Game.change_hp(-td)
		popup("-%d" % td, pc, Color("#9c5cd4"))
	if Game.stacks("infect") >= 3:
		Game.change_hp(-2)
	if Game.has("regen"):
		Game.heal(5)
	# timed battle statuses
	for id in Game.statuses.keys():
		var st: Dictionary = Game.statuses[id]
		if int(st.get("turns", -1)) > 0:
			st["turns"] = int(st["turns"]) - 1
			if int(st["turns"]) <= 0 and id != "stun":
				Game.remove_status(id)
	if Game.has("insane") and rng.randf() < 0.3:
		log_msg(Loc.t(["Someone is standing right behind you.", "The enemy smiles with your face.", "\"You were dead from the very beginning.\""][rng.randi() % 3]), "#9c8cff")
	# enemy statuses
	for e in _alive():
		var ec := _enemy_center(e)
		var st_e: Dictionary = e["st"]
		if st_e.has("bleed"):
			var bd := 3 * int(st_e["bleed"]["stacks"]) + int(e["max_hp"] * 0.02)
			e["hp"] = maxi(0, e["hp"] - bd)
			popup("-%d" % bd, ec, Color("#c8323a"))
		if st_e.has("burn"):
			var b2 := 5 + int(e["max_hp"] * 0.03)
			e["hp"] = maxi(0, e["hp"] - b2)
			popup("-%d" % b2, ec, Color("#ffa848"))
		for k in st_e.keys():
			if k == "stun":
				continue
			st_e[k]["turns"] = int(st_e[k]["turns"]) - 1
			if int(st_e[k]["turns"]) <= 0 and not (k == "blind" and e["blinded"]):
				st_e.erase(k)
		_refresh_enemy_status(e)
		if e["hp"] <= 0:
			await _kill(e)
	_refresh_player()
	await wait(0.35)


# =============================================================== results
func _victory() -> void:
	await wait(0.4)
	Sfx.music("", 0.4)
	Sfx.play("victory", 0.0)
	banner(Loc.t("VICTORY!"), Color("#7ec45c"))
	var exp_total := 0
	var gold_total := 0
	var loot: Array = []
	for e in enemies:
		if e["fled"]:
			continue
		exp_total += int(e["exp"])
		var g: Array = e["gold"]
		gold_total += rng.randi_range(int(g[0]), int(g[1])) + int(e["stolen_gold"])
		for it in e["stolen_items"]:
			loot.append(it)
		for row in DB.ENEMIES[e["id"]].get("loot", []):
			if rng.randf() < float(row[1]) * (1.0 + Game.luck() * 0.02):
				loot.append(row[0])
	Game.change_gold(gold_total)
	var bonus_gold := 0
	for it in loot:
		if it == "koin_bonus":
			var before := Game.gold
			Game.add_item(it)
			bonus_gold += Game.gold - before
		else:
			Game.add_item(it)
	var ups := Game.gain_exp(exp_total)
	Game.clear_battle_statuses()
	var lines := "[color=#ffd86a]EXP +%d[/color]   [color=#ffe86a]%s +%d[/color]" % [exp_total, Loc.t("Coins"), gold_total + bonus_gold]
	var item_names: Array = []
	for it in loot:
		if it != "koin_bonus":
			item_names.append(DB.item_name(it))
	if not item_names.is_empty():
		lines += "\n[color=#c6e0a0]%s: %s[/color]" % [Loc.t("Loot"), ", ".join(item_names)]
	for u in ups:
		lines += "\n" + Loc.t("LEVEL UP! Lv.%d Full heal.") % u["level"]
		if not u["skills"].is_empty():
			lines += "\n[color=#9c8cff]%s: %s[/color]" % [Loc.t("New skill"), ", ".join(u["skills"])]
	if not ups.is_empty():
		Sfx.play("levelup", 0.0)
	await dialog.ask(Loc.t("VICTORY"), lines, [Loc.t("Continue")], DB.icon("exp"))
	_finish({"result": "win"})



func _defeat() -> void:
	_set_pose("hurt")
	Sfx.music("", 0.4)
	Sfx.play("death", 0.0)
	var tw := create_tween()
	tw.tween_property(player_spr, "modulate", Color(0.4, 0.1, 0.1, 0.0), 1.2)
	await tw.finished
	var killer := Loc.t("an enemy")
	for e in enemies:
		if e["alive"]:
			killer = DB.enemy_name(e["id"])
			break
	var reason := Loc.t("Killed by %s.") % killer
	Game.trigger_game_over(reason)
	Game.goto("res://scenes/gameover.tscn")


func _finish(r: Dictionary) -> void:
	over = true
	r["tile"] = tile_id
	r["kind"] = kind
	if r["result"] == "flee":
		Game.clear_battle_statuses()
	Game.pending_battle = {}
	Game.battle_result = r
	Game.goto("res://scenes/board.tscn")
