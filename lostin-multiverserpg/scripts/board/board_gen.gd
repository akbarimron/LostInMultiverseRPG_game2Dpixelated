class_name BoardGen
extends RefCounted
## Procedural maze-board generator.
## Nodes live on even grid cells, corridors on the odd cell between two nodes.
## A random spanning tree (labyrinth) + a few extra loops gives a "Monopoly maze":
## you roll dice, walk tile-by-tile and choose a direction at every junction.


static func generate(stage: int, seed_: int, cycle: int = 1) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_
	var info: Dictionary = DB.STAGES[stage]
	var gw: int = info["grid"].x
	var gh: int = info["grid"].y

	# ---------------------------------------------------------------- maze
	var visited := {}
	var edges: Array = []        # [Vector2i a, Vector2i b] in node coords
	var stack: Array = [Vector2i(0, gh - 1)]
	visited[Vector2i(0, gh - 1)] = true
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while not stack.is_empty():
		var cur: Vector2i = stack.back()
		var opts: Array = []
		for d in dirs:
			var n: Vector2i = cur + d
			if n.x >= 0 and n.y >= 0 and n.x < gw and n.y < gh and not visited.has(n):
				opts.append(n)
		if opts.is_empty():
			stack.pop_back()
			continue
		var nx: Vector2i = opts[rng.randi() % opts.size()]
		visited[nx] = true
		edges.append([cur, nx])
		stack.append(nx)

	# extra loops so the labyrinth has real choices
	var edge_set := {}
	for e in edges:
		edge_set[_ekey(e[0], e[1])] = true
	var extra := int(gw * gh * 0.2)
	var tries := 0
	while extra > 0 and tries < 400:
		tries += 1
		var a := Vector2i(rng.randi() % gw, rng.randi() % gh)
		var d: Vector2i = dirs[rng.randi() % 4]
		var b := a + d
		if b.x < 0 or b.y < 0 or b.x >= gw or b.y >= gh:
			continue
		var k := _ekey(a, b)
		if edge_set.has(k):
			continue
		edge_set[k] = true
		edges.append([a, b])
		extra -= 1

	# ---------------------------------------------------------------- tiles
	var tiles: Array = []
	var by_cell := {}
	var add_tile := func(cell: Vector2i) -> int:
		if by_cell.has(cell):
			return by_cell[cell]
		var t := {"id": tiles.size(), "cell": cell, "type": "empty", "nb": [], "revealed": false,
			"visited": false, "cleared": false, "hidden": false, "data": {}}
		tiles.append(t)
		by_cell[cell] = t["id"]
		return t["id"]
	for y in gh:
		for x in gw:
			add_tile.call(Vector2i(x * 2, y * 2))
	for e in edges:
		var a: Vector2i = e[0] * 2
		var b: Vector2i = e[1] * 2
		var mid := (a + b) / 2
		var ia: int = by_cell[a]
		var ib: int = by_cell[b]
		var im: int = add_tile.call(mid)
		tiles[ia]["nb"].append(im)
		tiles[im]["nb"].append(ia)
		tiles[im]["nb"].append(ib)
		tiles[ib]["nb"].append(im)

	var start: int = by_cell[Vector2i(0, (gh - 1) * 2)]
	var dist := _bfs(tiles, start)
	# gate = farthest node (prefer dead ends / far corner)
	var gate := start
	var best := -1
	for t in tiles:
		var c: Vector2i = t["cell"]
		if c.x % 2 == 0 and c.y % 2 == 0:
			var dd: int = dist[t["id"]] + (3 if t["nb"].size() == 1 else 0)
			if dd > best:
				best = dd
				gate = t["id"]
	var maxd: int = dist[gate]

	tiles[start]["type"] = "start"
	tiles[start]["cleared"] = true
	tiles[gate]["type"] = "boss"
	tiles[gate]["data"] = {"enemies": [info["boss"]]}

	var free: Array = []
	for t in tiles:
		var id: int = t["id"]
		if id == start or id == gate:
			continue
		if dist[id] <= 2:
			continue
		free.append(id)

	var taken := {}
	var put := func(id: int, type: String) -> void:
		tiles[id]["type"] = type
		taken[id] = true

	# rest stop right before the boss
	for nb in tiles[gate]["nb"]:
		put.call(nb, "rest")
	# dead ends -> treasure / item / shrine
	for id in free:
		if tiles[id]["nb"].size() == 1 and not taken.has(id):
			var r := rng.randf()
			put.call(id, "treasure" if r < 0.6 else ("item" if r < 0.85 else "shrine"))
	# merchants at ~35% and ~70% of the way
	for frac in [0.35, 0.7]:
		var id := _closest_dist(tiles, dist, free, taken, int(maxd * frac), rng)
		if id >= 0:
			put.call(id, "merchant")
	# elites
	var n_elite := 1 if stage == 1 else 2
	for i in n_elite:
		var id := _closest_dist(tiles, dist, free, taken, int(maxd * (0.6 + 0.2 * i)), rng)
		if id >= 0:
			put.call(id, "elite")
	# mid rest
	var rid := _closest_dist(tiles, dist, free, taken, int(maxd * 0.5), rng)
	if rid >= 0:
		put.call(rid, "rest")
	# warps (stage 2+)
	if stage >= 2:
		var w1 := _closest_dist(tiles, dist, free, taken, int(maxd * 0.25), rng)
		if w1 >= 0:
			put.call(w1, "warp")
			var w2 := _closest_dist(tiles, dist, free, taken, int(maxd * 0.8), rng)
			if w2 >= 0:
				put.call(w2, "warp")
				tiles[w1]["data"]["to"] = w2
				tiles[w2]["data"]["to"] = w1
			else:
				tiles[w1]["type"] = "empty"
	# everything else: weighted random
	var table := [["enemy", 31], ["empty", 30], ["event", 13], ["item", 9], ["trap", 9], ["treasure", 3], ["shrine", 3], ["rest", 2]]
	var total := 0
	for row in table:
		total += int(row[1])
	for id in free:
		if taken.has(id):
			continue
		var r := rng.randi() % total
		for row in table:
			r -= int(row[1])
			if r < 0:
				tiles[id]["type"] = row[0]
				break

	# ---------------------------------------------------------------- per-tile data
	for t in tiles:
		var id: int = t["id"]
		match t["type"]:
			"enemy":
				var depth := float(dist[id]) / maxf(1.0, maxd)
				var n := 1
				var r := rng.randf()
				if r < 0.25 + depth * 0.35:
					n = 2
				if r < 0.06 + depth * 0.22:
					n = 3
				var group: Array = []
				for k in n:
					var pool: Array = info["enemies"]
					group.append(pool[rng.randi() % pool.size()])
				t["data"] = {"enemies": group}
			"elite":
				var ep: Array = info["elite"]
				var g2: Array = [ep[rng.randi() % ep.size()]]
				if stage >= 2 and rng.randf() < 0.5:
					g2.append(info["enemies"][rng.randi() % info["enemies"].size()])
				t["data"] = {"enemies": g2}
			"treasure":
				t["data"] = {"locked": rng.randf() < 0.35, "mimic": rng.randf() < (0.08 + 0.06 * stage)}
			"trap":
				t["hidden"] = rng.randf() < 0.5
				t["data"] = {"kind": ["bear", "spike", "gas", "pit"][rng.randi() % 4]}
			"event":
				t["data"] = {"seed": rng.randi()}

	# ---------------------------------------------------------------- decor props
	var props: Array = []
	var pkeys: Array = DB_props(stage)
	for y in range(-2, gh * 2 + 1):
		for x in range(-2, gw * 2 + 1):
			var c := Vector2i(x, y)
			if by_cell.has(c):
				continue
			if rng.randf() < 0.22:
				props.append({"cell": c, "p": pkeys[rng.randi() % pkeys.size()], "off": Vector2i(rng.randi_range(-6, 6), rng.randi_range(-6, 4))})

	return {"tiles": tiles, "start": start, "gate": gate, "w": gw * 2 - 1, "h": gh * 2 - 1,
		"props": props, "stage": stage, "cycle": cycle, "maxd": maxd}


static func DB_props(stage: int) -> Array:
	return {1: ["lamp", "trash", "building", "cone"], 2: ["lava", "bones", "spike", "deadtree"],
		3: ["vein", "eyestalk", "pustule", "teeth"]}[stage]


static func _ekey(a: Vector2i, b: Vector2i) -> String:
	if a.x < b.x or (a.x == b.x and a.y < b.y):
		return "%d,%d-%d,%d" % [a.x, a.y, b.x, b.y]
	return "%d,%d-%d,%d" % [b.x, b.y, a.x, a.y]


static func _bfs(tiles: Array, from: int) -> Dictionary:
	var dist := {from: 0}
	var q := [from]
	while not q.is_empty():
		var t: int = q.pop_front()
		for n in tiles[t]["nb"]:
			if not dist.has(n):
				dist[n] = int(dist[t]) + 1
				q.append(n)
	return dist


static func _closest_dist(tiles: Array, dist: Dictionary, free: Array, taken: Dictionary, target: int, rng: RandomNumberGenerator) -> int:
	var best := -1
	var bd := 9999
	for id in free:
		if taken.has(id):
			continue
		var d: int = abs(int(dist[id]) - target) * 10 + rng.randi() % 7
		if d < bd:
			bd = d
			best = id
	return best


## Path (list of tile ids) from a to b using BFS; used by warp/minimap helpers.
static func distances(tiles: Array, from: int) -> Dictionary:
	return _bfs(tiles, from)
