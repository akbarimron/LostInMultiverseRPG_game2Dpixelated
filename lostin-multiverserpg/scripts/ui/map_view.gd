class_name MapView
extends Control
## Draws the current board as a map (used by minimap + full map overlay).

var cell_px := 4
var tile_px := 3
var blink := 0.0
var show_legend_colors := true


func setup(cell: int, tile: int) -> void:
	cell_px = cell
	tile_px = tile
	_resize()


func _resize() -> void:
	if Game.board.is_empty():
		return
	custom_minimum_size = Vector2((int(Game.board["w"]) + 1) * cell_px, (int(Game.board["h"]) + 1) * cell_px)


func _process(delta: float) -> void:
	blink += delta
	queue_redraw()


func _draw() -> void:
	if Game.board.is_empty():
		return
	_resize()
	var tiles: Array = Game.board["tiles"]
	var off := Vector2(cell_px / 2.0, cell_px / 2.0)
	# Blind: the map stays readable but blurry (dim + wobble), with a small warning
	var blind := Game.has("blind")
	var fade := 0.45 if blind else 1.0
	if blind:
		off += Vector2(round(sin(blink * 7.0)), round(cos(blink * 5.0)))
	# links
	for t in tiles:
		if not t["revealed"]:
			continue
		for nb in t["nb"]:
			if nb < t["id"] or not tiles[nb]["revealed"]:
				continue
			var a: Vector2 = Vector2(t["cell"]) * cell_px + off
			var b: Vector2 = Vector2(tiles[nb]["cell"]) * cell_px + off
			draw_line(a, b, Color(0.42, 0.35, 0.52, fade), maxf(1.0, floorf(tile_px / 2.5)))
	# tiles
	for t in tiles:
		if not t["revealed"]:
			continue
		var type := shown_type(t)
		var col: Color = DB.TILE_INFO.get(type, DB.TILE_INFO["empty"])["color"]
		if type == "empty":
			col = Color("#5a4e6a")
		if t["cleared"] and type not in ["start", "merchant", "warp"]:
			col = col.darkened(0.55)
		var p: Vector2 = Vector2(t["cell"]) * cell_px + off - Vector2(tile_px, tile_px) / 2.0
		col.a *= fade
		draw_rect(Rect2(p.floor(), Vector2(tile_px, tile_px)), col)
		if t["visited"] and cell_px >= 6:
			draw_rect(Rect2(p.floor(), Vector2(tile_px, tile_px)), Color(1, 1, 1, 0.25), false, 1.0)
	# player
	if Game.pos >= 0:
		var pp: Vector2 = Vector2(tiles[Game.pos]["cell"]) * cell_px + off
		var s := float(tile_px) + 2.0
		var c := Color.WHITE if fmod(blink, 0.6) < 0.4 else Color("#ffd86a")
		draw_rect(Rect2((pp - Vector2(s, s) / 2.0).floor(), Vector2(s, s)), c, false, 1.0)
		draw_rect(Rect2((pp - Vector2(1, 1)).floor(), Vector2(2, 2)), c)
	if blind:
		var font := get_theme_default_font()
		var txt := Loc.t("Blurry vision (Blind)")
		var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
		draw_rect(Rect2(Vector2(0, 0), Vector2(w + 4, 12)), Color(0.05, 0.02, 0.06, 0.8))
		draw_string(font, Vector2(2, 9), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#e85a42"))


static func shown_type(t: Dictionary) -> String:
	if t["type"] == "trap" and t.get("hidden", false) and not t["visited"] and Game.equip.get("accessory", "") != "x_kacamata":
		return "empty"
	return t["type"]
