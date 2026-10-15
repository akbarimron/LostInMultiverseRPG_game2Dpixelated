class_name SettingsDialog
extends Control
## Modal Settings popup for changing Language, Audio Volumes, and Display mode.
## Can be opened from Title screen, Pause menu, or [O] shortcut.

signal closed

var box: PanelContainer
var content_box: VBoxContainer
var title_lbl: Label


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	add_child(UI.dim_bg())
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	box = UI.panel()
	box.custom_minimum_size = Vector2(340, 0)
	center.add_child(box)

	var v := UI.vbox(5)
	box.add_child(v)

	var head := UI.hbox(4)
	v.add_child(head)
	title_lbl = UI.label(Loc.t("SETTINGS"), Color(), "TitleLabel")
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_lbl)

	var b_close := UI.button("X", _close)
	b_close.custom_minimum_size = Vector2(24, 20)
	head.add_child(b_close)

	v.add_child(HSeparator.new())

	content_box = UI.vbox(6)
	v.add_child(content_box)

	_refresh()


func _refresh() -> void:
	UI.clear(content_box)
	title_lbl.text = Loc.t("SETTINGS")

	# ---------------- Language Option
	var lang_row := UI.vbox(2)
	content_box.add_child(lang_row)
	lang_row.add_child(UI.label(Loc.t("Language") + ":", Color("#ffd86a")))

	var lang_btns := UI.hbox(4)
	lang_row.add_child(lang_btns)

	var b_en := UI.button("English", func(): _set_lang("en"), null, "TabButton")
	b_en.toggle_mode = true
	b_en.button_pressed = (Loc.lang == "en")
	b_en.custom_minimum_size = Vector2(120, 24)
	lang_btns.add_child(b_en)

	var b_id := UI.button("Bahasa Indonesia", func(): _set_lang("id"), null, "TabButton")
	b_id.toggle_mode = true
	b_id.button_pressed = (Loc.lang == "id")
	b_id.custom_minimum_size = Vector2(150, 24)
	lang_btns.add_child(b_id)

	content_box.add_child(HSeparator.new())

	# ---------------- Audio Options
	var audio_label := UI.label(Loc.t("Audio") + ":", Color("#ffd86a"))
	content_box.add_child(audio_label)

	# Music
	var music_row := UI.hbox(4)
	content_box.add_child(music_row)
	var mlbl := UI.label(Loc.t("Music Volume"), Color(), "DimLabel")
	mlbl.custom_minimum_size = Vector2(130, 0)
	music_row.add_child(mlbl)

	var m_down := UI.button("-", func(): Loc.set_music_vol(Loc.music_volume - 0.1))
	m_down.custom_minimum_size = Vector2(24, 20)
	music_row.add_child(m_down)

	var m_val := UI.label("%d%%" % int(round(Loc.music_volume * 100)), Color("#ffd86a"))
	m_val.custom_minimum_size = Vector2(40, 0)
	m_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	music_row.add_child(m_val)

	var m_up := UI.button("+", func(): Loc.set_music_vol(Loc.music_volume + 0.1))
	m_up.custom_minimum_size = Vector2(24, 20)
	music_row.add_child(m_up)

	# SFX
	var sfx_row := UI.hbox(4)
	content_box.add_child(sfx_row)
	var slbl := UI.label(Loc.t("SFX Volume"), Color(), "DimLabel")
	slbl.custom_minimum_size = Vector2(130, 0)
	sfx_row.add_child(slbl)

	var s_down := UI.button("-", func(): Loc.set_sfx_vol(Loc.sfx_volume - 0.1))
	s_down.custom_minimum_size = Vector2(24, 20)
	sfx_row.add_child(s_down)

	var s_val := UI.label("%d%%" % int(round(Loc.sfx_volume * 100)), Color("#ffd86a"))
	s_val.custom_minimum_size = Vector2(40, 0)
	s_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sfx_row.add_child(s_val)

	var s_up := UI.button("+", func(): Loc.set_sfx_vol(Loc.sfx_volume + 0.1))
	s_up.custom_minimum_size = Vector2(24, 20)
	sfx_row.add_child(s_up)

	# Mute
	var mute_row := UI.hbox(4)
	content_box.add_child(mute_row)
	var mute_text := "%s: %s" % [Loc.t("Mute Audio"), ("ON" if Loc.muted else "OFF")]
	var b_mute := UI.button(mute_text, func():
		Loc.set_muted_state(not Loc.muted)
		_refresh()
	)
	b_mute.custom_minimum_size = Vector2(180, 22)
	mute_row.add_child(b_mute)

	content_box.add_child(HSeparator.new())

	# ---------------- Display Option
	var disp_label := UI.label(Loc.t("Display") + ":", Color("#ffd86a"))
	content_box.add_child(disp_label)

	var disp_row := UI.hbox(4)
	content_box.add_child(disp_row)
	var disp_mode_text := Loc.t("Fullscreen") if Loc.fullscreen else Loc.t("Windowed")
	var b_fs := UI.button("%s: %s" % [Loc.t("Display"), disp_mode_text], func():
		Loc.set_fullscreen_state(not Loc.fullscreen)
		_refresh()
	)
	b_fs.custom_minimum_size = Vector2(180, 22)
	disp_row.add_child(b_fs)

	content_box.add_child(HSeparator.new())

	# Done button & copyright
	var bot := UI.hbox(4)
	content_box.add_child(bot)
	var dev_lbl := UI.label("Dev: @Hibareit • IG: @akbar_diy", Color("#8a7e96"), "DimLabel")
	bot.add_child(dev_lbl)
	bot.add_child(UI.spacer(0, 0, true))
	var done_btn := UI.button(Loc.t("Close [Esc]"), _close)
	done_btn.custom_minimum_size = Vector2(100, 24)
	bot.add_child(done_btn)
	done_btn.grab_focus()


func _set_lang(l: String) -> void:
	Loc.set_language(l)
	_refresh()


func _close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE, KEY_O]:
			get_viewport().set_input_as_handled()
			_close()
