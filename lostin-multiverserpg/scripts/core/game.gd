extends Node
## Global game state + rules. Autoload name: Game

signal message(text: String, color: Color)
signal stats_changed
signal status_changed

const SAVE_PATH := "user://save.dat"

const C_GOOD := Color("#7ec45c")
const C_BAD := Color("#e85a42")
const C_INFO := Color("#e8dcc8")
const C_GOLD := Color("#ffe86a")
const C_MIND := Color("#9c8cff")
const C_WARN := Color("#ffa848")

var rng := RandomNumberGenerator.new()

# ---------------------------------------------------------------- run state
var stage: int = 1
var cycle: int = 1
var player_name: String = "Raka"
var level: int = 1
var xp: int = 0
var hp: int = 100
var mind: int = 60
var hunger: int = 100          # 100 = kenyang penuh, 0 = kelaparan
var gold: int = 30
var base := {"hp": 100, "mind": 60, "atk": 6, "def": 2, "agi": 5, "luck": 3}
var inventory: Dictionary = {}
var equip := {"weapon": "w_penggaris", "armor": "a_seragam", "accessory": ""}
var statuses: Dictionary = {}     # id -> {"stacks": int, "turns": int, "steps": int, "count": int}
var skills: Array = []
var phobia: String = "gelap"
var steps_total: int = 0
var golden_die: bool = false
var weak_mark: Dictionary = {}    # analisis skill target
var kills: int = 0
var log_lines: Array = []

# board / battle hand-off
var board: Dictionary = {}
var pos: int = -1
var prev: int = -1
var pending_battle: Dictionary = {}
var battle_result: Dictionary = {}
var checkpoint: Dictionary = {}
var death_stats: Dictionary = {}
var has_run: bool = false

var theme: Theme


func _ready() -> void:
	rng.randomize()
	# project-wide theme lives in res://assets/gen/ui/pixel_theme.tres (gui/theme/custom),
	# baked from ThemeBuilder by tools/build_theme.gd. Fallback: build at runtime.
	if ResourceLoader.exists("res://assets/gen/ui/pixel_theme.tres"):
		theme = load("res://assets/gen/ui/pixel_theme.tres")
	else:
		theme = ThemeBuilder.build()
	get_tree().root.theme = theme
	process_mode = Node.PROCESS_MODE_ALWAYS


# =============================================================== new game
func new_game(pname: String = "Raka") -> void:
	stage = 1
	cycle = 1
	player_name = pname
	level = 1
	xp = 0
	base = {"hp": 100, "mind": 60, "atk": 6, "def": 2, "agi": 5, "luck": 3}
	inventory = {"perban": 2, "roti": 2, "air": 1, "kopi": 1, "batu": 2, "kain": 1}
	equip = {"weapon": "w_penggaris", "armor": "a_seragam", "accessory": ""}
	statuses = {}
	skills = []
	_unlock_skills()
	hp = max_hp()
	mind = max_mind()
	hunger = 100
	gold = 30
	steps_total = 0
	golden_die = false
	weak_mark = {}
	kills = 0
	log_lines = []
	phobia = DB.PHOBIAS.keys()[rng.randi() % DB.PHOBIAS.size()]
	board = {}
	pos = -1
	prev = -1
	pending_battle = {}
	battle_result = {}
	has_run = true


func start_stage(s: int) -> void:
	stage = s
	board = BoardGen.generate(stage, rng.randi(), cycle)
	pos = int(board["start"])
	prev = -1
	reveal_around(pos)
	checkpoint = snapshot()
	save_game()


# =============================================================== derived stats
func eq(slot: String) -> Dictionary:
	var id: String = equip.get(slot, "")
	if id == "":
		return {}
	return DB.item(id)


func _eq_sum(key: String) -> float:
	var t := 0.0
	for slot in ["weapon", "armor", "accessory"]:
		t += float(eq(slot).get(key, 0))
	return t


func max_hp() -> int:
	var m := float(base["hp"]) + (level - 1) * 9
	m *= 1.0 - 0.1 * stacks("infect")
	m -= [0, 5, 10, 20, 30, 40][clampi(stacks("hunger"), 0, 5)]
	return maxi(10, int(m))


func max_mind() -> int:
	var m := float(base["mind"]) + (level - 1) * 5 + _eq_sum("mind_bonus")
	m -= 5 * stacks("tumor")
	return maxi(10, int(m))


func atk() -> int:
	var w := eq("weapon")
	var a := float(base["atk"]) + (level - 1) * 1.5 + float(w.get("atk", 2))
	var mult := 1.0
	if has("frac_arm") and not has("adren"):
		mult -= 0.4
		if int(w.get("hands", 1)) == 2:
			mult -= 0.15
	if has("bloodlust"):
		mult += 0.5
	if has("adren"):
		mult += 0.25
	var hs := stacks("hunger")
	if hs >= 2:
		mult -= 0.1 * (hs - 1)
	return maxi(1, int(a * mult))


func defense() -> int:
	var d := float(base["def"]) + (level - 1) * 0.8 + _eq_sum("def")
	if has("def_down"):
		d *= 0.5
	return maxi(0, int(d))


func agi() -> int:
	var a := float(base["agi"]) + (level - 1) * 0.4 + _eq_sum("agi")
	if has("frac_leg") and not has("adren"):
		a = 0
	if has("haste"):
		a += 5
	return maxi(0, int(a))


func luck() -> int:
	return int(base["luck"]) + int((level - 1) / 3)


func accuracy() -> int:
	var w := eq("weapon")
	var a := float(w.get("acc", 90)) + float(eq("armor").get("acc", 0)) + float(eq("accessory").get("acc", 0))
	if has("blind"):
		a -= 40
	if has("hallu"):
		a -= 20
	return int(a)


func crit_chance() -> int:
	var c := 5 + luck() + int(eq("weapon").get("crit", 0))
	if has("focus"):
		c += 30
	return c


func dice_mod() -> int:
	var m := int(_eq_sum("dice"))
	if has("frac_leg") and not has("adren"):
		m -= 2
	if stacks("hunger") >= 4:
		m -= 1
	if has("haste"):
		m += 2
	return m


func resist(status_id: String) -> float:
	var r := 0.0
	for slot in ["armor", "accessory"]:
		r += float(eq(slot).get("resist", {}).get(status_id, 0.0))
	if has("blessed") and status_id in ["fear", "curse", "insane"]:
		r = 1.0
	return clampf(r, 0.0, 1.0)


func exp_needed() -> int:
	return int(18 * pow(level, 1.55))


# =============================================================== statuses
func has(id: String) -> bool:
	return statuses.has(id)


func stacks(id: String) -> int:
	return int(statuses.get(id, {}).get("stacks", 0))


## Try to inflict a status. Returns true if applied.
func add_status(id: String, n: int = 1, turns: int = -1, steps: int = -1, ignore_resist: bool = false) -> bool:
	if not DB.STATUS.has(id):
		return false
	if not ignore_resist and DB.STATUS[id]["bad"]:
		if rng.randf() < resist(id):
			emit_signal("message", Loc.t("You resisted %s!") % DB.status_name(id), C_GOOD)
			return false
	var mx: int = DB.STATUS[id]["max"]
	var s: Dictionary = statuses.get(id, {"stacks": 0, "turns": -1, "steps": -1, "count": 0})
	var before: int = s["stacks"]
	s["stacks"] = clampi(int(s["stacks"]) + n, 1, mx)
	if turns > 0:
		s["turns"] = maxi(int(s["turns"]), turns)
	if steps > 0:
		s["steps"] = maxi(int(s["steps"]), steps)
	statuses[id] = s
	if before == 0:
		_on_new_status(id)
	emit_signal("status_changed")
	emit_signal("stats_changed")
	return true


func _on_new_status(id: String) -> void:
	# Phobia: Hemophobia triggers on your own blood
	if id == "bleed" and phobia == "darah" and not has("fear"):
		add_status("fear", 1)
		emit_signal("message", Loc.t("The sight of your own blood... you panic! (Hemophobia)"), C_BAD)


func remove_status(id: String) -> void:
	if statuses.erase(id):
		emit_signal("status_changed")
		emit_signal("stats_changed")


func reduce_status(id: String, n: int) -> void:
	if not has(id):
		return
	var s: Dictionary = statuses[id]
	s["stacks"] = int(s["stacks"]) - n
	if s["stacks"] <= 0:
		remove_status(id)
	else:
		emit_signal("status_changed")
		emit_signal("stats_changed")


func clear_battle_statuses() -> void:
	for id in DB.BATTLE_ONLY:
		statuses.erase(id)
	if has("fear"):
		reduce_status("fear", 1)
	weak_mark = {}
	emit_signal("status_changed")
	emit_signal("stats_changed")


func update_hunger_status() -> void:
	var st := 0
	if hunger <= 0:
		st = 5
	elif hunger <= 15:
		st = 4
	elif hunger <= 30:
		st = 3
	elif hunger <= 45:
		st = 2
	elif hunger <= 60:
		st = 1
	var cur := stacks("hunger")
	if st != cur:
		if st == 0:
			statuses.erase("hunger")
		else:
			statuses["hunger"] = {"stacks": st, "turns": -1, "steps": -1, "count": 0}
			if st > cur:
				emit_signal("message", Loc.t("Your stomach growls... Hunger %s!") % DB.roman(st), C_WARN)
		emit_signal("status_changed")
		emit_signal("stats_changed")
	hp = mini(hp, max_hp())


func update_mind_status() -> void:
	if mind <= 0 and not has("insane"):
		mind = 0
		if resist("insane") < 1.0:
			statuses["insane"] = {"stacks": 1, "turns": -1, "steps": -1, "count": 0}
			emit_signal("message", Loc.t("Your mind SHATTERS. You start seeing things that aren't there..."), C_MIND)
			emit_signal("status_changed")
	elif mind >= 20 and has("insane"):
		remove_status("insane")
		emit_signal("message", Loc.t("Your sanity slowly returns."), C_GOOD)


func change_hp(d: int) -> void:
	hp = clampi(hp + d, 0, max_hp())
	emit_signal("stats_changed")


func change_mind(d: int) -> void:
	mind = clampi(mind + d, 0, max_mind())
	update_mind_status()
	emit_signal("stats_changed")


func change_hunger(d: int) -> void:
	hunger = clampi(hunger + d, 0, 100)
	update_hunger_status()
	emit_signal("stats_changed")


func change_gold(d: int) -> void:
	gold = maxi(0, gold + d)
	emit_signal("stats_changed")


func heal(amount: int) -> int:
	## Healing respects Trauma (inverted)
	if has("trauma"):
		var dmg := maxi(1, amount / 2)
		change_hp(-dmg)
		emit_signal("message", Loc.t("Severe Trauma! The healing tears your wounds open (-%d HP).") % dmg, C_BAD)
		return -dmg
	var before := hp
	change_hp(amount)
	return hp - before


## Effects for each step walked on the board. Returns true if player died.
func tick_step() -> bool:
	steps_total += 1
	# hunger
	var hloss := 1
	if has("parasite"):
		hloss += 1
	change_hunger(-hloss)
	if stacks("hunger") >= 5:
		change_hp(-3)
		emit_signal("message", Loc.t("Starvation eats at your body (-3 HP)."), C_BAD)
	# bleeding
	if has("bleed"):
		var b := stacks("bleed")
		change_hp(-b)
		statuses["bleed"]["count"] = int(statuses["bleed"]["count"]) + 1
		if int(statuses["bleed"]["count"]) % 6 == 0 and rng.randf() < 0.35:
			if add_status("infect", 1):
				emit_signal("message", Loc.t("Your untreated wound starts to fester... Infection!"), C_BAD)
	# infection
	if has("infect"):
		var s: Dictionary = statuses["infect"]
		s["count"] = int(s["count"]) + 1
		if int(s["count"]) % 12 == 0 and int(s["stacks"]) < 3:
			add_status("infect", 1, -1, -1, true)
			emit_signal("message", Loc.t("Your infection gets worse!"), C_BAD)
		if stacks("infect") >= 3:
			change_hp(-2)
			change_mind(-1)
	# poison
	if has("poison"):
		change_hp(-2)
		_count_down_steps("poison", 14)
	if has("toxic"):
		change_hp(-4)
		_count_down_steps("toxic", 10)
	# parasite drain
	if has("parasite") and rng.randf() < 0.12:
		change_hp(-3)
		emit_signal("message", Loc.t("Something squirms inside your belly... (-3 HP)"), C_BAD)
	# tumor growth
	if has("tumor"):
		var t: Dictionary = statuses["tumor"]
		t["count"] = int(t["count"]) + 1
		if int(t["count"]) % 9 == 0 and int(t["stacks"]) < 5:
			add_status("tumor", 1, -1, -1, true)
			emit_signal("message", Loc.t("The lump on your body grows... (Tumor %s)") % DB.roman(stacks("tumor")), C_BAD)
		if stacks("tumor") >= 5:
			change_hp(-5)
		mind = mini(mind, max_mind())
	# regen
	if has("regen"):
		change_hp(1)
	# timed board statuses
	for id in ["blind", "blessed", "regen", "haste"]:
		if has(id) and int(statuses[id]["steps"]) > 0:
			statuses[id]["steps"] = int(statuses[id]["steps"]) - 1
			if int(statuses[id]["steps"]) <= 0:
				remove_status(id)
				emit_signal("message", Loc.t("%s wore off.") % DB.status_name(id), C_INFO)
	# insanity whispers
	if has("insane") and rng.randf() < 0.15:
		var w := ["\"...you will never go home...\"", "Your shadow moves on its own.", "You hear your name called from under the ground.",
				"The walls are giggling.", "\"Roll the die. ROLL IT.\""]
		emit_signal("message", Loc.t(w[rng.randi() % w.size()]), C_MIND)
	emit_signal("stats_changed")
	return hp <= 0


func _count_down_steps(id: String, default_steps: int) -> void:
	var s: Dictionary = statuses[id]
	if int(s["steps"]) <= 0:
		s["steps"] = default_steps
	s["steps"] = int(s["steps"]) - 1
	if int(s["steps"]) <= 0:
		remove_status(id)
		emit_signal("message", Loc.t("%s fades.") % DB.status_name(id), C_GOOD)


# =============================================================== inventory
func count(id: String) -> int:
	return int(inventory.get(id, 0))


func add_item(id: String, n: int = 1) -> void:
	if id == "koin_bonus":
		change_gold(rng.randi_range(8, 25) * stage)
		return
	inventory[id] = count(id) + n
	emit_signal("stats_changed")


func remove_item(id: String, n: int = 1) -> bool:
	if count(id) < n:
		return false
	inventory[id] = count(id) - n
	if inventory[id] <= 0:
		inventory.erase(id)
	emit_signal("stats_changed")
	return true


func equip_item(id: String) -> String:
	var it := DB.item(id)
	var slot := ""
	match it.get("kind", ""):
		"weapon":
			slot = "weapon"
		"armor":
			slot = "armor"
		"accessory":
			slot = "accessory"
		_:
			return ""
	var old: String = equip.get(slot, "")
	if old != "" and old != "w_tangan":
		add_item(old)
	remove_item(id)
	equip[slot] = id
	hp = mini(hp, max_hp())
	mind = mini(mind, max_mind())
	emit_signal("stats_changed")
	return old


func unequip(slot: String) -> void:
	var old: String = equip.get(slot, "")
	if old == "" or old == "w_tangan":
		return
	add_item(old)
	equip[slot] = "w_tangan" if slot == "weapon" else ""
	hp = mini(hp, max_hp())
	mind = mini(mind, max_mind())
	emit_signal("stats_changed")


func can_craft(r: Dictionary) -> bool:
	for k in r["in"]:
		if count(k) < int(r["in"][k]):
			return false
	return true


func craft(r: Dictionary) -> bool:
	if not can_craft(r):
		return false
	for k in r["in"]:
		remove_item(k, int(r["in"][k]))
	add_item(r["out"], int(r["n"]))
	return true


## Use a consumable outside battle (or self-use inside battle). Returns list of messages.
func use_consumable(id: String) -> Array:
	var it := DB.item(id)
	var out: Array = []
	if it.is_empty() or count(id) <= 0:
		return out
	remove_item(id)
	if it.has("heal"):
		var h := heal(int(it["heal"]))
		if h > 0:
			out.append("+%d HP" % h)
	if it.has("mind"):
		change_mind(int(it["mind"]))
		out.append(Loc.t("Mind %+d") % int(it["mind"]))
	if it.has("food"):
		change_hunger(int(it["food"]))
		out.append(Loc.t("+%d Satiety") % int(it["food"]))
	for c in it.get("cure", []):
		if has(c):
			remove_status(c)
			out.append(Loc.t("%s cured") % DB.status_name(c))
	for c in it.get("cure_stage", {}):
		if has(c):
			reduce_status(c, int(it["cure_stage"][c]))
			out.append(Loc.t("%s reduced") % Loc.t(DB.STATUS[c]["name"]))
	for b in it.get("buff", {}):
		add_status(b, 1, -1, int(it["buff"][b]))
		out.append(DB.status_name(b))
	for r in it.get("risk", {}):
		if rng.randf() < float(it["risk"][r]):
			if add_status(r, 1):
				out.append(Loc.t("Oh no... %s!") % DB.status_name(r))
	match id:
		"dadu_emas":
			golden_die = true
			out.append(Loc.t("You can choose your next roll!"))
		"pisau_operasi":
			change_hp(-15)
			add_status("bleed", 1, -1, -1, true)
			out.append(Loc.t("Surgery successful. It hurts like hell (-15 HP)."))
	return out


# =============================================================== exp / level
func gain_exp(n: int) -> Array:
	xp += n
	var ups: Array = []
	while xp >= exp_needed():
		xp -= exp_needed()
		level += 1
		var before := skills.duplicate()
		_unlock_skills()
		hp = max_hp()
		mind = max_mind()
		var new_sk: Array = []
		for s in skills:
			if not before.has(s):
				new_sk.append(DB.skill_name(s))
		ups.append({"level": level, "skills": new_sk})
	emit_signal("stats_changed")
	return ups


func _unlock_skills() -> void:
	for id in DB.SKILLS:
		if int(DB.SKILLS[id]["lv"]) <= level and not skills.has(id):
			skills.append(id)


# =============================================================== board helpers
func tile(id: int) -> Dictionary:
	return board["tiles"][id]


func reveal_around(center: int) -> void:
	if board.is_empty():
		return
	var radius := 1 if has("blind") else 2
	var frontier := [center]
	var dist := {center: 0}
	while not frontier.is_empty():
		var t: int = frontier.pop_front()
		board["tiles"][t]["revealed"] = true
		if int(dist[t]) >= radius:
			continue
		for nb in board["tiles"][t]["nb"]:
			if not dist.has(nb):
				dist[nb] = int(dist[t]) + 1
				frontier.append(nb)
	board["tiles"][center]["visited"] = true


func add_log(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > 60:
		log_lines.pop_front()


# =============================================================== save / load
func snapshot() -> Dictionary:
	return {
		"stage": stage, "cycle": cycle, "player_name": player_name, "level": level, "xp": xp,
		"hp": hp, "mind": mind, "hunger": hunger, "gold": gold, "base": base.duplicate(),
		"inventory": inventory.duplicate(), "equip": equip.duplicate(), "statuses": statuses.duplicate(true),
		"skills": skills.duplicate(), "phobia": phobia, "steps_total": steps_total, "golden_die": golden_die,
		"kills": kills, "board": board.duplicate(true), "pos": pos, "prev": prev,
	}


func restore(d: Dictionary) -> void:
	stage = d["stage"]; cycle = d["cycle"]; player_name = d["player_name"]; level = d["level"]; xp = d["xp"]
	hp = d["hp"]; mind = d["mind"]; hunger = d["hunger"]; gold = d["gold"]; base = d["base"].duplicate()
	inventory = d["inventory"].duplicate(); equip = d["equip"].duplicate(); statuses = d["statuses"].duplicate(true)
	skills = d["skills"].duplicate(); phobia = d["phobia"]; steps_total = d["steps_total"]; golden_die = d["golden_die"]
	kills = d.get("kills", 0); board = d["board"].duplicate(true); pos = d["pos"]; prev = d["prev"]
	pending_battle = {}
	battle_result = {}
	has_run = true
	emit_signal("stats_changed")
	emit_signal("status_changed")


func trigger_game_over(reason: String) -> void:
	death_stats = {
		"reason": reason,
		"stage": stage,
		"level": level,
		"steps_total": steps_total,
		"kills": kills,
	}
	board["death_reason"] = reason
	pending_battle = {}
	battle_result = {}
	if not checkpoint.is_empty():
		restore(checkpoint)
		save_game()


func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_var({"run": snapshot(), "checkpoint": checkpoint})
		f.close()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return false
	var d = f.get_var()
	f.close()
	if typeof(d) != TYPE_DICTIONARY or not d.has("run"):
		return false
	checkpoint = d.get("checkpoint", {})
	var r: Dictionary = d["run"]
	# If saved run has 0 HP or death_reason, always restart from checkpoint
	if (int(r.get("hp", 100)) <= 0 or r.get("board", {}).has("death_reason")) and not checkpoint.is_empty():
		restore(checkpoint)
		save_game()
		return true
	restore(r)
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


# =============================================================== scene flow
func goto(scene: String) -> void:
	Transition.change_scene(scene)
