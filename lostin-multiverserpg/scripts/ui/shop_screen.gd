class_name ShopScreen
extends Control
## Merchant: buy weapons / armor / medicine, sell anything at 50%.

signal closed

var stock: Array = []
var mode := "buy"
var list_box: VBoxContainer
var info_box: VBoxContainer
var gold_lbl: Label
var greet: RichTextLabel
var tab_buy: Button
var tab_sell: Button
var merchant_name := "Mr. Darmo"

const GREETS := {
	1: ["Mr. Darmo", "Still wandering around this late, kid? Grab some supplies, the streets have gone mad."],
	2: ["Demon Merchant", "Hehehe... lost souls always need to shop. Your coins are still good here."],
	3: ["Mad Doctor", "A new patient! Come, come: medicine, knives, all sterile... more or less."],
}


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS


func setup(stage: int, seed_: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var pool: Array = DB.SHOP[stage].duplicate()
	# always the basics + a random selection of the rest
	stock = ["perban", "nasi", "air"]
	pool.shuffle()
	for id in pool:
		if stock.size() >= 14:
			break
		if not stock.has(id):
			stock.append(id)
	stock.sort_custom(func(a, b): return _order(a) < _order(b))
	merchant_name = GREETS[stage][0]


func _order(id: String) -> int:
	return ["consumable", "weapon", "armor", "accessory", "material"].find(DB.item(id)["kind"]) * 1000 + int(DB.item(id)["price"])


func _ready() -> void:
	add_child(UI.dim_bg())
	var root := UI.panel()
	root.position = Vector2(40, 16)
	root.size = Vector2(560, 328)
	add_child(root)
	var v := UI.vbox(4)
	root.add_child(v)
	var head := UI.hbox(6)
	v.add_child(head)
	head.add_child(UI.icon_rect(DB.tile_icon("merchant"), 2))
	var hv := UI.vbox(2)
	hv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(hv)
	hv.add_child(UI.label(Loc.t(merchant_name).to_upper(), Color(), "TitleLabel"))
	greet = UI.rich(Loc.t(GREETS[Game.stage][1]), true, 380)
	hv.add_child(greet)
	var gv := UI.vbox(2)
	head.add_child(gv)
	gold_lbl = UI.label("", Color("#ffe86a"))
	gv.add_child(gold_lbl)
	gv.add_child(UI.button(Loc.t("Done [Esc]"), _close))
	var tabs := UI.hbox(2)
	v.add_child(tabs)
	tab_buy = UI.button(Loc.t("Buy"), func(): _set_mode("buy"), null, "TabButton")
	tab_sell = UI.button(Loc.t("Sell"), func(): _set_mode("sell"), null, "TabButton")
	tab_buy.toggle_mode = true
	tab_sell.toggle_mode = true
	tabs.add_child(tab_buy)
	tabs.add_child(tab_sell)
	var body := UI.hbox(6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(body)
	var lp := UI.panel("PanelDark")
	lp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(lp)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 220)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lp.add_child(scroll)
	list_box = UI.vbox(1)
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list_box)
	var ip := UI.panel("PanelDark")
	ip.custom_minimum_size = Vector2(190, 0)
	body.add_child(ip)
	info_box = UI.vbox(4)
	ip.add_child(info_box)
	_set_mode("buy")


func _close() -> void:
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close()


func _set_mode(m: String) -> void:
	mode = m
	tab_buy.button_pressed = m == "buy"
	tab_sell.button_pressed = m == "sell"
	_refresh()


func _sell_price(id: String) -> int:
	return maxi(1, int(DB.item(id)["price"]) / 2)


func _buy_price(id: String) -> int:
	return int(ceil(float(DB.item(id)["price"]) * (1.0 + 0.15 * (Game.cycle - 1))))


func _refresh() -> void:
	gold_lbl.text = "%s: %d" % [Loc.t("Coins"), Game.gold]
	UI.clear(list_box)
	var ids: Array = stock if mode == "buy" else Game.inventory.keys()
	if mode == "sell":
		ids.sort_custom(func(a, b): return _order(a) < _order(b))
	for id in ids:
		var it := DB.item(id)
		var row := UI.hbox(4)
		var b := Button.new()
		b.theme_type_variation = "ListButton"
		b.icon = DB.item_icon(id)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var price := _buy_price(id) if mode == "buy" else _sell_price(id)
		var own := Game.count(id)
		var eq := ""
		for s in Game.equip:
			if Game.equip[s] == id:
				eq = " [E]"
		b.text = "%s%s%s" % [DB.item_name(id), eq, ("  (%s %d)" % [Loc.t("own"), own]) if own > 0 and mode == "buy" else ("  x%d" % own if mode == "sell" else "")]
		b.tooltip_text = UI.item_tooltip(id)
		var iid: String = id
		b.focus_entered.connect(func(): _show_info(iid))
		b.mouse_entered.connect(func(): _show_info(iid))
		b.pressed.connect(func(): _transact(iid))
		row.add_child(b)
		var pl := UI.label("%d" % price, Color("#ffe86a") if (mode == "sell" or Game.gold >= price) else Color("#e85a42"))
		pl.custom_minimum_size = Vector2(30, 0)
		pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(pl)
		row.add_child(UI.icon_rect(DB.icon("gold")))
		list_box.add_child(row)
	if ids.is_empty():
		list_box.add_child(UI.label(Loc.t("Nothing here."), Color(), "DimLabel"))
	_show_info(ids[0] if not ids.is_empty() else "")


func _show_info(id: String) -> void:
	UI.clear(info_box)
	if id == "":
		return
	var it := DB.item(id)
	var c := CenterContainer.new()
	c.add_child(UI.icon_rect(DB.item_icon(id), 3))
	info_box.add_child(c)
	info_box.add_child(UI.label(DB.item_name(id), Color("#ffd86a")))
	info_box.add_child(UI.label(DB.kind_label(it["kind"]), Color(), "DimLabel"))
	info_box.add_child(UI.rich(DB.item_desc(id), true, 176))
	var cmp := _compare(id)
	if cmp != "":
		info_box.add_child(UI.rich(cmp, true, 176))
	var hint: String = (Loc.t("Click to BUY (%d coins)") % _buy_price(id)) if mode == "buy" else (Loc.t("Click to SELL (+%d coins)") % _sell_price(id))
	info_box.add_child(UI.label(hint, Color(), "DimLabel"))


func _compare(id: String) -> String:
	var it := DB.item(id)
	var slot: String = {"weapon": "weapon", "armor": "armor", "accessory": "accessory"}.get(it["kind"], "")
	if slot == "":
		return ""
	var cur := Game.eq(slot)
	var cur_name: String = DB.item_name(Game.equip.get(slot, "")) if Game.equip.get(slot, "") != "" else "-"
	var s := "[color=#8a7e96]%s: %s[/color]\n" % [Loc.t("Equipped"), cur_name]
	if slot == "weapon":
		var d := int(it.get("atk", 0)) - int(cur.get("atk", 0))
		s += "ATK [color=%s]%+d[/color]" % ["#7ec45c" if d >= 0 else "#e85a42", d]
	else:
		var d2 := int(it.get("def", 0)) - int(cur.get("def", 0))
		s += "DEF [color=%s]%+d[/color]" % ["#7ec45c" if d2 >= 0 else "#e85a42", d2]
	return s


func _transact(id: String) -> void:
	if mode == "buy":
		var price := _buy_price(id)
		if Game.gold < price:
			Sfx.play("error")
			greet.text = "\"%s\"" % Loc.t("Not enough money, kid. No credit here.")
			return
		Game.change_gold(-price)
		Game.add_item(id)
		Sfx.play("buy")
		greet.text = "\"%s\"" % (Loc.t("%s! Good choice.") % DB.item_name(id))
		Game.emit_signal("message", Loc.t("Bought %s (-%d coins).") % [DB.item_name(id), price], Game.C_GOLD)
	else:
		if Game.count(id) <= 0:
			return
		Game.remove_item(id)
		Game.change_gold(_sell_price(id))
		Sfx.play("coin")
		greet.text = "\"%s\"" % (Loc.t("Hmm, %s. I'll take it.") % DB.item_name(id))
	_refresh()
