extends Control
## Game over: retry from the stage checkpoint, or go back to the title.

var dialog: GameDialog


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("#0a0306")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var skull := UI.icon_rect(DB.icon("skull"), 4)
	skull.position = Vector2(300, 60)
	add_child(skull)
	var t := UI.label(Loc.t("YOU LOST CONSCIOUSNESS..."), Color("#e85a42"), "BigLabel")
	t.add_theme_color_override("font_color", Color("#e85a42"))
	t.position = Vector2(0, 116)
	t.size = Vector2(640, 24)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(t)
	var reason: String = Game.death_stats.get("reason", Game.board.get("death_reason", Loc.t("You couldn't go on.")))
	var stg: int = int(Game.death_stats.get("stage", Game.stage))
	var lvl: int = int(Game.death_stats.get("level", Game.level))
	var steps: int = int(Game.death_stats.get("steps_total", Game.steps_total))
	var kills_cnt: int = int(Game.death_stats.get("kills", Game.kills))
	var info := UI.label("%s\n%s %d • Lv.%d • %d %s • %d %s" % [
		Loc.t(reason), Loc.t("Stage"), stg, lvl, steps, Loc.t("steps"), kills_cnt, Loc.t("enemies defeated")], Color("#a89ab8"))
	info.position = Vector2(0, 150)
	info.size = Vector2(640, 30)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(info)
	var v := UI.vbox(4)
	v.position = Vector2(230, 200)
	v.custom_minimum_size = Vector2(180, 0)
	add_child(v)
	var b1 := UI.button(Loc.t("Retry Stage %d") % stg, _retry)
	b1.disabled = Game.checkpoint.is_empty()
	v.add_child(b1)
	v.add_child(UI.button(Loc.t("Main Menu"), _on_main_menu))
	Sfx.music("music_title")
	(b1 if not b1.disabled else v.get_child(1)).grab_focus()
	modulate.a = 0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.0)


func _retry() -> void:
	if not Game.checkpoint.is_empty():
		Game.restore(Game.checkpoint)
		Game.save_game()
	Game.goto("res://scenes/board.tscn")


func _on_main_menu() -> void:
	if not Game.checkpoint.is_empty():
		Game.restore(Game.checkpoint)
		Game.save_game()
	Game.goto("res://scenes/title.tscn")
