extends Node2D
## Board game scene: roll dice, walk the labyrinth tile by tile, resolve tile events.

const T := 32
const G := "res://assets/gen/"

enum S { IDLE, ROLLING, MOVING, CHOOSING, EVENT, OVERLAY }
var state: S = S.IDLE

var world: Node2D
var links: Node2D
var tiles_root: Node2D
var token: Node2D
var token_spr: Sprite2D
var choice_root: Node2D
var cam: Camera2D
var hud: BoardHUD
var ui_layer: CanvasLayer
var dialog: GameDialog
var events: BoardEvents
var tile_nodes: Array = []
var _choice_opts: Array = []
var _choice_dirs: Dictionary = {}
var _bob_t := 0.0
var _hover_tile := -1
var _tex_idle: Texture2D = preload("res://assets/gen/chars/player_front.png")
var _tex_idle2: Texture2D = preload("res://assets/gen/chars/player_front2.png")

signal choice_made(tile_id: int)


func _ready() -> void:
	if Game.board.is_empty():
		if not Game.has_run:
			Game.new_game()
		Game.start_stage(Game.stage)
	_build_world()
	_build_ui()
	events = BoardEvents.new(self)
	Game.message.connect(_on_message)
	Loc.language_changed.connect(_on_language_changed)
	Sfx.music(DB.STAGES[Game.stage]["music"])
	cam.position = _tile_center(Game.pos)
	cam.reset_smoothing()
	_refresh_all_tiles()
	_after_load.call_deferred()


func _exit_tree() -> void:
	if Game.message.is_connected(_on_message):
		Game.message.disconnect(_on_message)


func _after_load() -> void:
	# returning from a battle?
	if not Game.battle_result.is_empty():
		var r: Dictionary = Game.battle_result
		Game.battle_result = {}
		await events.after_battle(r)
	elif not Game.board.get("intro_done", false):
		Game.board["intro_done"] = true
		await stage_intro()
	_set_idle()


func _on_message(text: String, col: Color) -> void:
	if hud:
		hud.push_log(text, col)
	Game.add_log(text)


# =============================================================== world building
func _build_world() -> void:
	world = Node2D.new()
	add_child(world)
	var w: int = Game.board["w"]
	var h: int = Game.board["h"]
	var ground := TextureRect.new()
	ground.texture = load(G + "tiles/ground_s%d.png" % Game.stage)
	ground.stretch_mode = TextureRect.STRETCH_TILE
	ground.position = Vector2(-T * 10, -T * 8)
	ground.size = Vector2((w + 20) * T, (h + 16) * T)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(ground)
	# props
	var props := Node2D.new()
	world.add_child(props)
	for p in Game.board["props"]:
		var s := Sprite2D.new()
		s.texture = load(G + "props/s%d_%s.png" % [Game.stage, p["p"]])
		s.centered = false
		s.position = Vector2(p["cell"]) * T + Vector2(p["off"])
		s.modulate = Color(0.7, 0.66, 0.78)
		props.add_child(s)
	links = Node2D.new()
	links.draw.connect(_draw_links)
	world.add_child(links)
	tiles_root = Node2D.new()
	world.add_child(tiles_root)
	tile_nodes.clear()
	var stage: int = Game.stage
	for t in Game.board["tiles"]:
		var n := Node2D.new()
		n.position = Vector2(t["cell"]) * T
		var plate := Sprite2D.new()
		plate.name = "Plate"
		plate.centered = false
		var c: Vector2i = t["cell"]
		plate.texture = load(G + "tiles/plate_s%d_%d.png" % [stage, (c.x * 7 + c.y * 3) % 4])
		n.add_child(plate)
		var rim := Sprite2D.new()
		rim.name = "Rim"
		rim.centered = false
		rim.texture = load(G + "tiles/rim.png")
		n.add_child(rim)
		var icon := Sprite2D.new()
		icon.name = "Icon"
		icon.position = Vector2(16, 14)
		n.add_child(icon)
		var fog := Sprite2D.new()
		fog.name = "Fog"
		fog.centered = false
		fog.texture = load(G + "tiles/fog.png")
		fog.modulate = Color(1, 1, 1, 0.5)
		n.add_child(fog)
		tiles_root.add_child(n)
		tile_nodes.append(n)
	choice_root = Node2D.new()
	world.add_child(choice_root)
	# token
	token = Node2D.new()
	var sh := Sprite2D.new()
	sh.texture = load(G + "ui/shadow.png")
	sh.position = Vector2(0, 1)
	token.add_child(sh)
	token_spr = Sprite2D.new()
	token_spr.texture = load(G + "chars/player_front.png")
	token_spr.offset = Vector2(0, -13)
	token.add_child(token_spr)
	world.add_child(token)
	token.position = _tile_center(Game.pos) + Vector2(0, 6)
	cam = Camera2D.new()
	cam.zoom = Vector2(2, 2)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 6.0
	cam.limit_left = -T * 6
	cam.limit_top = -T * 4
	cam.limit_right = (w + 6) * T
	cam.limit_bottom = (h + 5) * T
	add_child(cam)
	cam.make_current()


func _tile_center(id: int) -> Vector2:
	return Vector2(Game.tile(id)["cell"]) * T + Vector2(16, 16)


func _draw_links() -> void:
	var tiles: Array = Game.board["tiles"]
	var col_out := Color("#07050b")
	var col_in: Color = {1: Color("#3a3e58"), 2: Color("#3a1014"), 3: Color("#5a1a2a")}[Game.stage]
	for t in tiles:
		if not t["revealed"]:
			continue
		for nb in t["nb"]:
			if nb < t["id"]:
				continue
			if not tiles[nb]["revealed"]:
				continue
			var a := _tile_center(t["id"])
			var b := _tile_center(nb)
			links.draw_line(a, b, col_out, 12.0)
			links.draw_line(a, b, col_in, 8.0)


func _refresh_tile(id: int) -> void:
	var t: Dictionary = Game.tile(id)
	var n: Node2D = tile_nodes[id]
	var fog: Sprite2D = n.get_node("Fog")
	var plate: Sprite2D = n.get_node("Plate")
	var rim: Sprite2D = n.get_node("Rim")
	var icon: Sprite2D = n.get_node("Icon")
	if not t["revealed"]:
		fog.visible = true
		plate.visible = false
		rim.visible = false
		icon.visible = false
		return
	fog.visible = false
	plate.visible = true
	var type := MapView.shown_type(t)
	var info: Dictionary = DB.TILE_INFO.get(type, DB.TILE_INFO["empty"])
	rim.visible = type != "empty"
	rim.modulate = info["color"]
	icon.visible = true
	var done: bool = t["cleared"] and not type in ["start", "merchant", "warp"]
	if type == "empty":
		icon.texture = DB.tile_icon("cleared") if t["visited"] else null
	elif done:
		icon.texture = DB.tile_icon(type)
		icon.modulate = Color(0.35, 0.32, 0.4, 0.8)
		rim.modulate = info["color"].darkened(0.6)
	else:
		icon.texture = DB.tile_icon(type)
		icon.modulate = Color.WHITE
	plate.modulate = Color(1, 1, 1) if not t["visited"] else Color(0.86, 0.84, 0.9)


func _refresh_all_tiles() -> void:
	for t in Game.board["tiles"]:
		_refresh_tile(t["id"])
	links.queue_redraw()
	if hud and hud.minimap:
		hud.minimap.queue_redraw()


# =============================================================== UI
func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 5
	add_child(ui_layer)
	hud = BoardHUD.new()
	ui_layer.add_child(hud)
	hud.roll_pressed.connect(_on_roll_pressed)
	hud.bag_pressed.connect(open_inventory)
	hud.map_pressed.connect(open_map)
	hud.guide_pressed.connect(open_guide)
	hud.menu_pressed.connect(open_menu)
	for l in Game.log_lines.slice(maxi(0, Game.log_lines.size() - 4)):
		hud.push_log(l, Color("#a89ab8"))
	var top := CanvasLayer.new()
	top.layer = 20
	add_child(top)
	dialog = GameDialog.new()
	top.add_child(dialog)


func _set_idle() -> void:
	state = S.IDLE
	hud.set_roll_enabled(true)
	Game.save_game()


# =============================================================== input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_hover()
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventScreenTouch and event.pressed):
		if state == S.CHOOSING:
			if hud and hud.is_mouse_over_ui():
				return
			var id := _tile_at_mouse()
			if id in _choice_opts:
				get_viewport().set_input_as_handled()
				choice_made.emit(id)
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var k: int = event.keycode
	if state == S.CHOOSING:
		var dir := Vector2i.ZERO
		match k:
			KEY_LEFT, KEY_A: dir = Vector2i(-1, 0)
			KEY_RIGHT, KEY_D: dir = Vector2i(1, 0)
			KEY_UP, KEY_W: dir = Vector2i(0, -1)
			KEY_DOWN, KEY_S: dir = Vector2i(0, 1)
		if _choice_dirs.has(dir):
			get_viewport().set_input_as_handled()
			choice_made.emit(_choice_dirs[dir])
		return
	if state != S.IDLE:
		return
	match k:
		KEY_SPACE, KEY_ENTER:
			_on_roll_pressed()
		KEY_I, KEY_TAB:
			open_inventory()
		KEY_M:
			open_map()
		KEY_G:
			open_guide()
		KEY_O:
			open_settings()
		KEY_ESCAPE:
			open_menu()
	get_viewport().set_input_as_handled()


func _tile_at_mouse() -> int:
	var p := world.get_global_mouse_position()
	var c := Vector2i(floori(p.x / T), floori(p.y / T))
	for t in Game.board["tiles"]:
		if t["cell"] == c:
			return t["id"]
	return -1


func _update_hover() -> void:
	if hud and hud.is_mouse_over_ui():
		if _hover_tile != -1:
			_hover_tile = -1
			hud.show_tile_info("", Vector2.ZERO)
		return
	var id := _tile_at_mouse()
	if id == _hover_tile:
		if id >= 0:
			hud.show_tile_info(hud.tile_info_lbl.text, get_viewport().get_mouse_position())
		return
	_hover_tile = id
	if id < 0 or not Game.tile(id)["revealed"] or state == S.OVERLAY:
		hud.show_tile_info("", Vector2.ZERO)
		return
	var t: Dictionary = Game.tile(id)
	var type := MapView.shown_type(t)
	var info: Dictionary = DB.TILE_INFO[type]
	var txt := "[color=#%s]%s[/color]" % [info["color"].to_html(false), DB.tile_name(type)]
	if t["cleared"] and type in ["enemy", "elite", "treasure", "item", "trap", "event", "rest", "shrine", "boss"]:
		txt += " [color=#8a7e96]%s[/color]" % Loc.t("(cleared)")
	else:
		txt += "\n[color=#a89ab8]%s[/color]" % DB.tile_desc(type)
		if type in ["enemy", "elite", "boss"] and t["data"].has("enemies"):
			var names: Array = []
			for e in t["data"]["enemies"]:
				names.append(DB.enemy_name(e))
			txt += "\n[color=#e85a42]%s[/color]" % ", ".join(names)
	if id == Game.pos:
		txt += "\n[color=#ffd86a]%s[/color]" % Loc.t("(you are here)")
	hud.show_tile_info(txt, get_viewport().get_mouse_position())


func _process(delta: float) -> void:
	_bob_t += delta
	if token_spr:
		token_spr.texture = _tex_idle if fmod(_bob_t, 1.0) < 0.5 else _tex_idle2
	if state != S.MOVING and cam:
		cam.position = token.position


# =============================================================== rolling & moving
func _on_roll_pressed() -> void:
	if state != S.IDLE:
		return
	state = S.ROLLING
	hud.set_roll_enabled(false)
	hud.show_tile_info("", Vector2.ZERO)
	var n := await roll_die()
	var total := n
	var notes: Array = []
	if Game.has("curse") and Game.rng.randf() < 0.3:
		total = 1
		notes.append(Loc.t("Curse! forced to 1"))
		Game.change_gold(-int(Game.gold * 0.03))
	var mod := Game.dice_mod()
	if mod != 0:
		notes.append("%+d" % mod)
	total = maxi(1, total + mod)
	var msg := Loc.t("Dice: %d steps") % total if notes.is_empty() else (Loc.t("Dice: %d") % n + " (%s) = %d %s" % [", ".join(notes), total, Loc.t("steps")])
	hud.dice_lbl.text = "%d" % total
	Game.emit_signal("message", msg, Color("#ffd86a"))
	var died := await move_steps(total)
	if died:
		await game_over(Loc.t("Your body collapsed along the way..."))
		return
	await events.resolve(Game.pos)
	if Game.hp <= 0:
		await game_over(Loc.t("You can no longer stand..."))
		return
	if not Transition.busy:
		_set_idle()


func roll_die() -> int:
	if Game.golden_die:
		Game.golden_die = false
		var pick := await dialog.ask(Loc.t("Golden Die"), Loc.t("A golden die gleams in your hand. Choose your number!"),
			["1", "2", "3", "4", "5", "6"], DB.item_icon("dadu_emas"))
		hud.show_die(pick + 1)
		Sfx.play("dice_land")
		return pick + 1
	Sfx.play("dice", 0.0)
	var tw := create_tween()
	tw.tween_property(hud.dice_rect, "scale", Vector2(1.15, 1.15), 0.1)
	tw.tween_property(hud.dice_rect, "scale", Vector2.ONE, 0.1)
	for i in 10:
		hud.dice_rect.texture = load(G + ("dice/die_blur.png" if i % 3 == 0 else "dice/die_%d.png" % Game.rng.randi_range(1, 6)))
		await get_tree().create_timer(0.045 + i * 0.012).timeout
	var n := Game.rng.randi_range(1, 6)
	hud.show_die(n)
	Sfx.play("dice_land")
	var tw2 := create_tween()
	tw2.tween_property(hud.dice_rect, "scale", Vector2(1.3, 1.3), 0.06)
	tw2.tween_property(hud.dice_rect, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(0.25).timeout
	return n


## Walk n steps; returns true if the player died on the way.
func move_steps(n: int) -> bool:
	state = S.MOVING
	var left := n
	while left > 0:
		var here: int = Game.pos
		var nbs: Array = Game.tile(here)["nb"]
		var opts: Array = []
		for x in nbs:
			if x != Game.prev:
				opts.append(x)
		if opts.is_empty():
			opts = [Game.prev] if Game.prev >= 0 else nbs.duplicate()
		var next: int = opts[0]
		if opts.size() > 1:
			next = await choose_direction(opts, left)
		await hop_to(next)
		Game.prev = here
		Game.pos = next
		Game.reveal_around(next)
		_refresh_all_tiles()
		left -= 1
		if Game.tick_step():
			return true
		var t: Dictionary = Game.tile(next)
		# the boss gate stops you no matter what (Monopoly "go to jail" style)
		if t["type"] == "boss" and not t["cleared"] and left > 0:
			Game.emit_signal("message", Loc.t("A terrifying aura stops you in your tracks!"), Color("#c64c98"))
			break
		# hidden traps can snap shut even when passing by
		if t["type"] == "trap" and t["hidden"] and not t["cleared"] and left > 0 and Game.rng.randf() < 0.35:
			await events.resolve(next)
			if Game.hp <= 0:
				return true
			break
	return false


func hop_to(id: int) -> void:
	var from := token.position
	var to := _tile_center(id) + Vector2(0, 6)
	Sfx.play("step", 0.15, -4)
	if to.x < from.x:
		token_spr.flip_h = true
	elif to.x > from.x:
		token_spr.flip_h = false
	var tw := create_tween()
	tw.tween_method(func(t: float): token.position = from.lerp(to, t) + Vector2(0, -sin(t * PI) * 8).round(), 0.0, 1.0, 0.17)
	await tw.finished
	token.position = to
	cam.position = to


func choose_direction(opts: Array, left: int) -> int:
	state = S.CHOOSING
	UI.clear(choice_root)
	_choice_opts = opts
	_choice_dirs.clear()
	var here := _tile_center(Game.pos)
	for o in opts:
		var c := _tile_center(o)
		var d := (c - here).normalized()
		var dir := Vector2i(roundi(d.x), roundi(d.y))
		_choice_dirs[dir] = o
		var arrow := Sprite2D.new()
		arrow.texture = load(G + "ui/arrow_right.png")
		arrow.position = here.lerp(c, 0.5).round()
		if dir == Vector2i(-1, 0):
			arrow.flip_h = true
		elif dir == Vector2i(0, -1):
			arrow.rotation_degrees = -90
		elif dir == Vector2i(0, 1):
			arrow.rotation_degrees = 90
		choice_root.add_child(arrow)
		var tw := arrow.create_tween().set_loops()
		tw.tween_property(arrow, "modulate", Color(1.6, 1.4, 0.6), 0.3)
		tw.tween_property(arrow, "modulate", Color.WHITE, 0.3)
		# highlight target tile
		var hl := Sprite2D.new()
		hl.texture = load(G + "tiles/rim.png")
		hl.centered = false
		hl.position = Vector2(Game.tile(o)["cell"]) * T
		hl.modulate = Color("#ffd86a")
		choice_root.add_child(hl)
	hud.set_roll_enabled(false, Loc.t("Choose direction: arrows/click (%d steps left)") % left)
	hud.show_direction_buttons(_choice_dirs, func(picked_id: int): choice_made.emit(picked_id))
	Sfx.play("move")
	var picked: int = await choice_made
	hud.hide_direction_buttons()
	UI.clear(choice_root)
	state = S.MOVING
	hud.set_roll_enabled(false, "...")
	return picked


## Teleport the token (warp / flee).
func teleport(id: int, fx: bool = true) -> void:
	if fx:
		Sfx.play("portal")
		var tw := create_tween()
		tw.tween_property(token, "modulate:a", 0.0, 0.3)
		await tw.finished
	Game.prev = -1
	Game.pos = id
	Game.reveal_around(id)
	token.position = _tile_center(id) + Vector2(0, 6)
	cam.position = token.position
	_refresh_all_tiles()
	if fx:
		var tw2 := create_tween()
		tw2.tween_property(token, "modulate:a", 1.0, 0.3)
		await tw2.finished


func step_back() -> void:
	## move the token back to the previous tile (fleeing / refusing the boss)
	var back: int = Game.prev
	if back < 0:
		var nbs: Array = Game.tile(Game.pos)["nb"]
		back = nbs[0]
	var here := Game.pos
	await hop_to(back)
	Game.pos = back
	Game.prev = here
	_refresh_all_tiles()


# =============================================================== overlays
func open_inventory() -> void:
	if state != S.IDLE:
		return
	state = S.OVERLAY
	hud.show_tile_info("", Vector2.ZERO)
	var inv := InventoryScreen.new()
	ui_layer.add_child(inv)
	Sfx.play("open", 0.05, -8)
	await inv.closed
	_refresh_all_tiles()
	_set_idle()


func open_map() -> void:
	if state != S.IDLE:
		return
	state = S.OVERLAY
	var ov := Control.new()
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.add_child(UI.dim_bg())
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.add_child(cc)
	var p := UI.panel()
	cc.add_child(p)
	var v := UI.vbox(4)
	p.add_child(v)
	var info: Dictionary = DB.STAGES[Game.stage]
	v.add_child(UI.label(Loc.t("MAP") + " • %s (%s)" % [DB.stage_name(Game.stage), DB.stage_sub(Game.stage)], Color(), "TitleLabel"))
	var h := UI.hbox(10)
	v.add_child(h)
	var mv := MapView.new()
	mv.setup(14, 10)
	h.add_child(mv)
	var legend := UI.vbox(1)
	h.add_child(legend)
	for k in ["start", "enemy", "elite", "boss", "treasure", "item", "merchant", "trap", "event", "rest", "shrine", "warp"]:
		if k == "warp" and Game.stage < 2:
			continue
		var row := UI.hbox(3)
		var sw := ColorRect.new()
		sw.color = DB.TILE_INFO[k]["color"]
		sw.custom_minimum_size = Vector2(7, 7)
		sw.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(sw)
		row.add_child(UI.icon_rect(DB.tile_icon(k)))
		row.add_child(UI.label(DB.tile_name(k)))
		legend.add_child(row)
	legend.add_child(UI.spacer(0, 4))
	legend.add_child(UI.label(Loc.t("Steps: %d") % Game.steps_total, Color(), "DimLabel"))
	legend.add_child(UI.label(Loc.t("Enemies defeated: %d") % Game.kills, Color(), "DimLabel"))
	v.add_child(UI.label(Loc.t("[M]/[Esc]/Click to close. Dark tiles = unexplored."), Color(), "DimLabel"))
	ui_layer.add_child(ov)
	Sfx.play("open", 0.05, -8)
	ov.gui_input.connect(func(e): _map_input(ov, e))
	ov.mouse_filter = Control.MOUSE_FILTER_STOP
	ov.focus_mode = Control.FOCUS_ALL
	ov.grab_focus()
	await ov.tree_exited
	_set_idle()


func _map_input(ov: Control, e: InputEvent) -> void:
	if (e is InputEventMouseButton and e.pressed) or (e is InputEventKey and e.pressed and e.keycode in [KEY_M, KEY_ESCAPE, KEY_SPACE]):
		ov.queue_free()


func open_guide(chapter: String = "welcome") -> void:
	if state != S.IDLE and state != S.OVERLAY:
		return
	var prev_state := state
	state = S.OVERLAY
	hud.show_tile_info("", Vector2.ZERO)
	var gb := GuideBook.new()
	gb.start_chapter = chapter
	ui_layer.add_child(gb)
	await gb.closed
	if prev_state == S.IDLE:
		_set_idle()
	else:
		state = prev_state


func open_shop(seed_: int) -> void:
	state = S.OVERLAY
	var shop := ShopScreen.new()
	shop.setup(Game.stage, seed_)
	ui_layer.add_child(shop)
	Sfx.play("open", 0.05, -8)
	await shop.closed
	state = S.EVENT


func open_settings() -> void:
	var prev_state := state
	state = S.OVERLAY
	hud.show_tile_info("", Vector2.ZERO)
	var s := SettingsDialog.new()
	ui_layer.add_child(s)
	await s.closed
	hud.refresh()
	_refresh_all_tiles()
	if prev_state == S.IDLE:
		_set_idle()
	else:
		state = prev_state


func _on_language_changed(_l: String) -> void:
	# messages already in the log were written in the old language -> clear them
	Game.log_lines.clear()
	_hover_tile = -1
	if hud:
		hud.clear_log()
		hud.show_tile_info("", Vector2.ZERO)
		if state == S.IDLE:
			hud.set_roll_enabled(true)
		hud.refresh()
	_refresh_all_tiles()


func open_menu() -> void:
	if state != S.IDLE:
		return
	state = S.OVERLAY
	while true:
		var c := await dialog.ask(Loc.t("PAUSED"), Loc.t("Stage %d • %s\nSteps %d • Lv.%d • %d gold") % [
			Game.stage, DB.stage_name(Game.stage), Game.steps_total, Game.level, Game.gold],
			[Loc.t("Resume"), Loc.t("Guide Book [G]"), Loc.t("Settings [O]"), Loc.t("Save & Quit to Title")], DB.icon("skull"), "", 0)
		match c:
			0:
				break
			1:
				await open_guide("welcome")
			2:
				await open_settings()
			3:
				Game.save_game()
				Game.goto("res://scenes/title.tscn")
				return
	_set_idle()


func show_help() -> void:
	await open_guide("welcome")


# =============================================================== stage flow
func stage_intro() -> void:
	var info: Dictionary = DB.STAGES[Game.stage]
	state = S.EVENT
	var card := Control.new()
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("#05030a")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(bg)
	var v := UI.vbox(6)
	v.position = Vector2(60, 120)
	v.size = Vector2(520, 120)
	card.add_child(v)
	var l1 := UI.label("%s %d" % [Loc.t("Stage"), Game.stage], Color("#8a7e96"))
	l1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l1)
	var l2 := UI.label(DB.stage_name(Game.stage).to_upper(), Color(), "BigLabel")
	l2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l2.add_theme_color_override("font_color", info["rim"])
	v.add_child(l2)
	var l3 := UI.label(Loc.t(info["intro"]), Color("#c8b8e0"))
	l3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l3)
	var l4 := UI.label(Loc.t("- click / space -"), Color(), "DimLabel")
	l4.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l4)
	ui_layer.add_child(card)
	card.modulate.a = 0
	var tw := create_tween()
	tw.tween_property(card, "modulate:a", 1.0, 0.6)
	Sfx.play("portal" if Game.stage > 1 else "growl", 0.0)
	await tw.finished
	await _wait_any_key(card)
	var tw2 := create_tween()
	tw2.tween_property(card, "modulate:a", 0.0, 0.5)
	await tw2.finished
	card.queue_free()
	if Game.stage == 1 and Game.cycle == 1:
		await dialog.ask(Loc.t("Hidden Phobia"), Loc.t("Ever since you were young, you've harbored an inexplicable fear:\n[color=#c64c98]%s[/color]\n\nEnemies that trigger your phobia will make you [color=#e85a42]Terrified[/color].") % Loc.t(DB.PHOBIAS[Game.phobia]["name"]),
			[Loc.t("I have to go home...")], DB.status_icon("fear"))
		await open_guide("welcome")


func _wait_any_key(node: Control) -> void:
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	while true:
		await get_tree().process_frame
		if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			break
	await get_tree().create_timer(0.15).timeout


func next_stage() -> void:
	if Game.stage >= 3:
		Game.goto("res://scenes/ending.tscn")
		return
	Game.stage += 1
	Game.start_stage(Game.stage)
	Game.goto("res://scenes/board.tscn")


func game_over(reason: String) -> void:
	state = S.EVENT
	Game.trigger_game_over(reason)
	Game.goto("res://scenes/gameover.tscn")
