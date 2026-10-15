extends Control
## Ending after Stage 3 boss: stats + new cycle (NG+).


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/gen/bg/bg_title.png")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.modulate = Color(0.5, 0.45, 0.6)
	add_child(bg)
	var p := UI.panel()
	p.position = Vector2(120, 60)
	p.custom_minimum_size = Vector2(400, 0)
	add_child(p)
	var v := UI.vbox(6)
	p.add_child(v)
	var t := UI.label(Loc.t("YOU WAKE UP."), Color(), "BigLabel")
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	v.add_child(UI.rich(Loc.t("Your alarm is ringing. Your school uniform hangs on the closet door, clean, not a drop of blood.\nIt was all a dream... right?\n\nBut there is still a [color=#e85a42]bite mark[/color] on your palm, and in your pocket... a [color=#ffe86a]Golden Die[/color]."), true, 380))
	v.add_child(HSeparator.new())
	v.add_child(UI.rich("[color=#a89ab8]%s • Lv.%d • %d %s • %d %s • %d %s • %s %d[/color]\n[color=#8a7e96]Lost in Multiverse RPG • (c) Developer @Hibareit • IG: @akbar_diy[/color]" % [
		Game.player_name, Game.level, Game.steps_total, Loc.t("steps"), Game.kills, Loc.t("enemies"), Game.gold, Loc.t("coins"), Loc.t("Cycle"), Game.cycle], true, 380))
	var h := UI.hbox(6)
	v.add_child(h)
	var b1 := UI.button(Loc.t("New Cycle (harder)"), _new_cycle)
	h.add_child(b1)
	h.add_child(UI.button(Loc.t("Main Menu"), func(): Game.delete_save(); Game.goto("res://scenes/title.tscn")))
	Sfx.play("victory", 0.0)
	Sfx.music("music_title")
	b1.grab_focus()


func _new_cycle() -> void:
	Game.cycle += 1
	Game.add_item("dadu_emas")
	Game.hp = Game.max_hp()
	Game.mind = Game.max_mind()
	Game.hunger = 100
	Game.start_stage(1)
	Game.board["intro_done"] = false
	Game.goto("res://scenes/board.tscn")
