extends Control
## Title screen: new game (with name), continue, how to play, quit.

const G := "res://assets/gen/"
var menu: VBoxContainer
var name_edit: LineEdit
var dialog: GameDialog
var player_spr: TextureRect
var t := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.texture = load(G + "bg/bg_title.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(bg)
	player_spr = UI.icon_rect(load(G + "chars/player_front.png"), 3)
	player_spr.position = Vector2(272, 168)
	add_child(player_spr)
	var title := UI.label("LOST IN MULTIVERSE", Color(), "BigLabel")
	title.position = Vector2(0, 32)
	title.size = Vector2(640, 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	var p := UI.panel()
	p.position = Vector2(450, 120)
	p.custom_minimum_size = Vector2(170, 0)
	add_child(p)
	menu = UI.vbox(3)
	p.add_child(menu)
	var foot := UI.label("", Color(), "DimLabel")
	foot.name = "FootLabel"
	foot.position = Vector2(6, 344)
	add_child(foot)
	var copy_lbl := UI.label("(c) Developer @Hibareit • IG: @akbar_diy", Color("#8a7e96"), "DimLabel")
	copy_lbl.name = "CopyLabel"
	copy_lbl.position = Vector2(0, 344)
	copy_lbl.size = Vector2(634, 16)
	copy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(copy_lbl)
	_rebuild_menu()
	dialog = GameDialog.new()
	add_child(dialog)
	Sfx.music("music_title")
	Loc.language_changed.connect(func(_l): _rebuild_menu())


func _rebuild_menu() -> void:
	var cur_name: String = name_edit.text if (name_edit != null and is_instance_valid(name_edit)) else "Raka"
	UI.clear(menu)
	menu.add_child(UI.label(Loc.t("Name") + ":", Color(), "DimLabel"))
	name_edit = LineEdit.new()
	name_edit.text = cur_name
	name_edit.max_length = 12
	menu.add_child(name_edit)
	var b_new := UI.button(Loc.t("New Game"), _on_new)
	menu.add_child(b_new)
	var b_cont := UI.button(Loc.t("Continue"), _on_continue)
	b_cont.disabled = not Game.has_save()
	menu.add_child(b_cont)
	menu.add_child(UI.button(Loc.t("Guide Book"), _on_guide))
	menu.add_child(UI.button(Loc.t("Settings"), _on_settings))
	menu.add_child(UI.button(Loc.t("Quit"), func(): get_tree().quit()))
	(b_cont if not b_cont.disabled else b_new).grab_focus()
	var fl: Label = get_node_or_null("FootLabel")
	if fl:
		fl.text = Loc.t("v0.3 • [Space] roll • [I] bag • [M] map • [G] guide • [O] options")


func _process(delta: float) -> void:
	t += delta
	player_spr.position.y = 168 + (1 if fmod(t, 1.0) < 0.5 else 0) * 3


func _on_new() -> void:
	if Game.has_save():
		var c: int = await dialog.ask(Loc.t("New Game?"), Loc.t("Your previous save will be overwritten."), [Loc.t("Yes, start over"), Loc.t("Cancel")])
		if c != 0:
			return
	var nm := name_edit.text.strip_edges()
	if nm == "":
		nm = "Raka"
	Game.new_game(nm)
	Game.start_stage(1)
	Game.goto("res://scenes/board.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G:
			_on_guide()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_O:
			_on_settings()
			get_viewport().set_input_as_handled()


func _on_continue() -> void:
	if Game.load_game():
		Game.goto("res://scenes/board.tscn")
	else:
		Sfx.play("error")


func _on_guide() -> void:
	var gb := GuideBook.new()
	add_child(gb)
	await gb.closed


func _on_settings() -> void:
	var s := SettingsDialog.new()
	add_child(s)
	await s.closed


func _on_help() -> void:
	_on_guide()
