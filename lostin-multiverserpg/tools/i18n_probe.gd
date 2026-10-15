extends RefCounted
## Dev helper for language QA: collects every visible text on screen.
## Used from the MCP game_eval:  var P = load("res://tools/i18n_probe.gd")

static var seen: Dictionary = {}


static func collect(node: Node, out: Dictionary = {}) -> Dictionary:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return out
	if node is RichTextLabel:
		_add(out, (node as RichTextLabel).get_parsed_text())
	elif node is Label:
		_add(out, (node as Label).text)
	elif node is Button:
		_add(out, (node as Button).text)
	elif node is LineEdit:
		pass
	if node is Control and (node as Control).tooltip_text != "":
		_add(out, (node as Control).tooltip_text)
	for c in node.get_children():
		collect(c, out)
	return out


static func _add(out: Dictionary, t: String) -> void:
	t = t.strip_edges()
	if t.length() > 1:
		out[t] = true
		seen[t] = true


static func snap(tree: SceneTree) -> Array:
	return collect(tree.root).keys()


## Answer every open GameDialog with `pick`, recording what it said.
static func drain_dialogs(tree: SceneTree, pick: int = 0, max_n: int = 8) -> Array:
	var log: Array = []
	for i in max_n:
		var d: GameDialog = _find_dialog(tree.root)
		if d == null:
			break
		log.append(d.title_lbl.text + " | " + d.body.get_parsed_text())
		for b in d._buttons:
			_add(seen, b.text)
		_add(seen, d.title_lbl.text)
		_add(seen, d.body.get_parsed_text())
		var p := pick
		if p >= d._buttons.size() or d._buttons[p].disabled:
			p = 0
			for k in d._buttons.size():
				if not d._buttons[k].disabled:
					p = k
					break
		d._pick(p)
		await tree.create_timer(0.35).timeout
	return log


static func _find_dialog(n: Node) -> GameDialog:
	if n is GameDialog and (n as GameDialog).visible and n._open:
		return n
	for c in n.get_children():
		var r := _find_dialog(c)
		if r:
			return r
	return null
