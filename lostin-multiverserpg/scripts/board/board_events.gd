class_name BoardEvents
extends RefCounted
## Everything that happens when you land on a tile. Fully localized via Loc.tr.

var b  # board.gd
var rng: RandomNumberGenerator


func _init(board) -> void:
	b = board
	rng = Game.rng


func _msg(t: String, c: Color = Game.C_INFO) -> void:
	Game.emit_signal("message", t, c)


func _clear(id: int) -> void:
	Game.tile(id)["cleared"] = true
	b._refresh_all_tiles()


func _icon(type: String) -> Texture2D:
	return DB.tile_icon(type)


# =============================================================== dispatcher
func resolve(id: int) -> void:
	var t: Dictionary = Game.tile(id)
	b.state = b.S.EVENT
	if t["cleared"] and not t["type"] in ["merchant", "warp", "boss"]:
		if t["type"] == "start":
			_msg(Loc.t("Back at the start. Still far from home..."), Game.C_INFO)
		return
	match t["type"]:
		"empty":
			await _empty(id)
		"enemy", "elite":
			await _battle_tile(id, t["type"])
		"boss":
			await _boss(id)
		"treasure":
			await _treasure(id)
		"item":
			await _item(id)
		"merchant":
			await _merchant(id)
		"trap":
			await _trap(id)
		"event":
			await _event(id)
		"rest":
			await _rest(id)
		"shrine":
			await _shrine(id)
		"warp":
			await _warp(id)


func start_battle(enemies: Array, tile_id: int, kind: String) -> void:
	Game.pending_battle = {"enemies": enemies.duplicate(), "tile": tile_id, "kind": kind}
	Sfx.play("boss" if kind == "boss" else "encounter", 0.0)
	await Transition.flash(Color("#6a0a14") if kind != "boss" else Color("#3a0a4a"), 0.2)
	Game.save_game()
	Game.goto("res://scenes/battle.tscn")


func after_battle(r: Dictionary) -> void:
	var id: int = r.get("tile", -1)
	match r.get("result", ""):
		"win":
			if id >= 0:
				_clear(id)
			if r.get("kind", "") == "boss":
				await _stage_clear()
		"flee":
			_msg(Loc.t("You ran away in terror!"), Game.C_WARN)
			await b.step_back()


# =============================================================== tiles
func _empty(id: int) -> void:
	var r := rng.randf()
	if r < 0.06:
		var g := rng.randi_range(2, 6) * Game.stage
		Game.change_gold(g)
		Sfx.play("coin")
		_msg(Loc.t("You found %d coins in the gutter.") % g, Game.C_GOLD)
	elif r < 0.10 and Game.stage >= 2:
		Game.change_mind(-4)
		Sfx.play("whisper")
		_msg(Loc.t("Something whispers from the dark... (Mind -4)"), Game.C_MIND)


func _battle_tile(id: int, type: String) -> void:
	var t: Dictionary = Game.tile(id)
	var enemies: Array = t["data"].get("enemies", ["preman"])
	var names: Array = []
	for e in enemies:
		names.append(DB.enemy_name(e))
	_msg(Loc.t("%s blocks the way!") % ", ".join(names), Game.C_BAD)
	await start_battle(enemies, id, type)


func _boss(id: int) -> void:
	var t: Dictionary = Game.tile(id)
	var boss_id: String = t["data"]["enemies"][0]
	var e: Dictionary = DB.ENEMIES[boss_id]
	var boss_name := DB.enemy_name(boss_id)
	var prompt := Loc.t("The dimensional gate pulses behind them. %s blocks your way home.\n\n[color=#e85a42]This is a BOSS battle. Cannot flee.[/color]\nHP %d • ATK %d") % [boss_name, int(e["hp"]), int(e["atk"])]
	var c: int = await b.dialog.ask(boss_name, prompt, [Loc.t("Fight!"), Loc.t("Step back (retreat 1 step)")], DB.enemy_tex(boss_id), "PanelRed")
	if c == 0:
		await start_battle([boss_id], id, "boss")
	else:
		await b.step_back()


func _stage_clear() -> void:
	Sfx.play("portal", 0.0)
	var st_name: String = DB.stage_name(Game.stage)
	var txt := Loc.t("The guardian %s falls. The gate opens wide, emitting light that... does not feel like home.") % st_name
	if Game.stage >= 3:
		txt = Loc.t("The Mother Mass bursts into light. Beyond its flesh... you see your bedroom lamp.")
	await b.dialog.ask(Loc.t("GATE OPEN"), txt, [Loc.t("Enter gate")], DB.tile_icon("gate"))
	b.next_stage()


func _loot_text(items: Array, gold: int) -> String:
	var parts: Array = []
	if gold > 0:
		parts.append("[color=#ffe86a]%d %s[/color]" % [gold, Loc.t("Coins").to_lower()])
	for it in items:
		parts.append("[color=#c6e0a0]%s[/color]" % DB.item_name(it))
	return ", ".join(parts)


func _give(items: Array, gold: int) -> void:
	for it in items:
		Game.add_item(it)
	if gold > 0:
		Game.change_gold(gold)


func _treasure(id: int) -> void:
	var t: Dictionary = Game.tile(id)
	var d: Dictionary = t["data"]
	var locked: bool = d.get("locked", false)
	var opts: Array = []
	var text := Loc.t("A wooden chest with iron bands lies among rubble.")
	if locked:
		text += "\n[color=#ffa848]" + Loc.t("This chest is LOCKED.") + "[/color]"
		opts = [
			{"text": Loc.t("Open with Old Key (have %d)") % Game.count("kunci"), "disabled": Game.count("kunci") <= 0},
			{"text": Loc.t("Lockpick (dice 4+, fail: arm might break)")},
			{"text": Loc.t("Smash open (contents may break)")},
			{"text": Loc.t("Leave it")},
		]
	else:
		opts = [Loc.t("Open chest"), Loc.t("Leave it")]
	var c: int = await b.dialog.ask(Loc.t("TREASURE CHEST"), text, opts, _icon("treasure"))
	var open := false
	var smashed := false
	if locked:
		match c:
			0:
				Game.remove_item("kunci")
				open = true
			1:
				var roll := rng.randi_range(1, 6) + (1 if Game.agi() >= 8 else 0)
				Sfx.play("dice_land")
				if roll >= 4:
					open = true
					_msg(Loc.t("Lockpick succeeded! (roll %d)") % roll, Game.C_GOOD)
				else:
					_msg(Loc.t("Lockpick failed! (roll %d)") % roll, Game.C_BAD)
					if rng.randf() < 0.4 and Game.add_status("frac_arm"):
						Sfx.play("hit_heavy")
						await b.dialog.info(Loc.t("Crack!"), Loc.t("Makeshift crowbar slips and hits your arm. Broken Arm!"), DB.status_icon("frac_arm"))
					return
			2:
				open = true
				smashed = true
				Sfx.play("hit_heavy")
			_:
				return
	else:
		if c != 0:
			return
		open = true
	if not open:
		return
	if d.get("mimic", false):
		Sfx.play("growl", 0.0)
		await b.dialog.ask("!!!", Loc.t("The chest opens... and rows of TEETH greet you.\nTHE CHEST IS ALIVE!"), [Loc.t("Fight!")], DB.enemy_tex("mimic"), "PanelRed")
		await start_battle(["mimic"], id, "mimic")
		return
	var gold := rng.randi_range(15, 40) * Game.stage
	var items: Array = []
	if not smashed:
		var tt: Array = DB.TREASURE_TABLE[Game.stage]
		items.append(tt[rng.randi() % tt.size()])
	if rng.randf() < 0.6:
		var ft: Array = DB.FIND_TABLE[Game.stage]
		items.append(ft[rng.randi() % ft.size()])
	if smashed:
		gold = int(gold * 0.7)
	_give(items, gold)
	Sfx.play("open")
	_clear(id)
	var loot_desc := Loc.t("You found: %s") % _loot_text(items, gold)
	if smashed:
		loot_desc += "\n[color=#8a7e96]" + Loc.t("(Part of the loot was destroyed...)") + "[/color]"
	await b.dialog.info(Loc.t("CHEST CONTENTS"), loot_desc, DB.item_icon("emas"))


func _item(id: int) -> void:
	var ft: Array = DB.FIND_TABLE[Game.stage]
	var items: Array = [ft[rng.randi() % ft.size()]]
	if rng.randf() < 0.4:
		items.append(ft[rng.randi() % ft.size()])
	var gold := rng.randi_range(0, 8) * Game.stage
	_give(items, gold)
	Sfx.play("coin")
	_clear(id)
	_msg(Loc.t("You found: %s") % _loot_text(items, gold).replace("[color=#ffe86a]", "").replace("[color=#c6e0a0]", "").replace("[/color]", ""), Game.C_GOOD)
	await b.dialog.info(Loc.t("LOOSE ITEMS"), Loc.t("Among trash and shadows, you find:\n%s") % _loot_text(items, gold), DB.item_icon(items[0]))


func _merchant(id: int) -> void:
	var c: int = await b.dialog.ask(Loc.t("MERCHANT"), Loc.t("A rickety cart with a lantern. The merchant smiles a little too wide."),
		[Loc.t("Take a look"), Loc.t("Just passing by")], _icon("merchant"))
	if c == 0:
		await b.open_shop(id * 97 + Game.stage * 13 + Game.steps_total / 30)
		b.state = b.S.EVENT


func _trap(id: int) -> void:
	var t: Dictionary = Game.tile(id)
	var kind: String = t["data"].get("kind", "bear")
	var hidden: bool = t.get("hidden", false) and Game.equip.get("accessory", "") != "x_kacamata" and not t["visited"]
	var names := {
		"bear": Loc.t("Bear Trap"),
		"spike": Loc.t("Spike Floor"),
		"gas": Loc.t("Poison Gas Pipe"),
		"pit": Loc.t("Hidden Pit")
	}
	var dodged := false
	if hidden:
		Sfx.play("trap", 0.0)
		var roll := rng.randi_range(1, 6)
		dodged = roll + int(Game.agi() / 4) >= 6
		if dodged:
			_msg(Loc.t("CLICK! Your reflexes save you from %s! (roll %d)") % [names[kind], roll], Game.C_GOOD)
			_clear(id)
			return
	else:
		var c: int = await b.dialog.ask(names[kind].to_upper(), Loc.t("You see a %s ahead. Too late to turn back.") % names[kind].to_lower(),
			[Loc.t("Jump over (dice 4+)"), {"text": Loc.t("Disarm with Scrap Iron (have %d)") % Game.count("besi"), "disabled": Game.count("besi") <= 0}],
			_icon("trap"))
		if c == 1:
			Game.remove_item("besi")
			Game.add_item("paku", 2)
			Sfx.play("select")
			_clear(id)
			await b.dialog.info(Loc.t("SUCCESS"), Loc.t("You propped the mechanism open. Gained 2 Nails."), DB.item_icon("paku"))
			return
		var roll2 := rng.randi_range(1, 6) + (1 if Game.agi() >= 8 else 0)
		Sfx.play("dice_land")
		if roll2 >= 4:
			_msg(Loc.t("Your leap was clean! (roll %d)") % roll2, Game.C_GOOD)
			_clear(id)
			return
		Sfx.play("trap", 0.0)
	# trap triggers
	var txt := ""
	match kind:
		"bear":
			Game.change_hp(-8)
			Game.add_status("frac_leg")
			Game.add_status("bleed")
			txt = Loc.t("Steel jaws clamp your leg! -8 HP, Broken Leg & Bleeding.")
		"spike":
			Game.change_hp(-12)
			Game.add_status("bleed", 2)
			txt = Loc.t("Rusty nails pierce your shoes! -12 HP, Bleeding II.")
		"gas":
			Game.change_hp(-5)
			Game.add_status("toxic" if Game.stage >= 2 else "poison")
			txt = Loc.t("Green smoke bursts in your face! -5 HP, Poisoned.")
		"pit":
			Game.change_hp(-10)
			Game.change_mind(-8)
			if rng.randf() < 0.4:
				Game.add_status("frac_arm")
			txt = Loc.t("Floor collapses! You fall into darkness. -10 HP, -8 Mind.")
	Sfx.play("hit_heavy")
	Transition.flash(Color("#6a0a14"), 0.25)
	_clear(id)
	await b.dialog.info(names[kind].to_upper(), txt, _icon("trap"), Loc.t("Ouch..."))


func _rest(id: int) -> void:
	var name_: String = DB.STAGES[Game.stage]["rest_name"]
	var opts: Array = [
		Loc.t("Sleep (HP +50%, Mind +40, Satiety -15, risk ambush)"),
		Loc.t("Treat wounds (stop Bleeding, Infection -1, Fear gone)"),
		{"text": Loc.t("Cook food (needs Mystery Meat: Satiety +60)"), "disabled": Game.count("daging") <= 0},
		Loc.t("Keep moving"),
	]
	var c: int = await b.dialog.ask(Loc.t(name_).to_upper(), Loc.t("A place that feels slightly safe. Just slightly."), opts, _icon("rest"))
	match c:
		0:
			_clear(id)
			if rng.randf() < 0.2:
				Sfx.play("growl", 0.0)
				await b.dialog.info(Loc.t("AMBUSHED!"), Loc.t("You awaken to footsteps... they've surrounded you!"), _icon("enemy"), Loc.t("Fight!"))
				var pool: Array = DB.STAGES[Game.stage]["enemies"]
				await start_battle([pool[rng.randi() % pool.size()], pool[rng.randi() % pool.size()]], -1, "ambush")
				return
			Game.heal(int(Game.max_hp() * 0.5))
			Game.change_mind(40)
			Game.change_hunger(-15)
			if Game.has("fear"):
				Game.remove_status("fear")
			Sfx.play("heal")
			_msg(Loc.t("Deep sleep... for now."), Game.C_GOOD)
		1:
			_clear(id)
			Game.remove_status("bleed")
			Game.reduce_status("infect", 1)
			Game.remove_status("fear")
			Game.heal(10)
			Sfx.play("heal")
			_msg(Loc.t("You clean and bandage your wounds."), Game.C_GOOD)
		2:
			Game.remove_item("daging")
			Game.change_hunger(60)
			Game.heal(8)
			Sfx.play("heal")
			_msg(Loc.t("Meat cooked thoroughly. Safe to eat... hopefully."), Game.C_GOOD)


func _shrine(id: int) -> void:
	var name_: String = DB.STAGES[Game.stage]["shrine_name"]
	var cost := 20 * Game.stage
	var opts: Array = [
		{"text": Loc.t("Pray (%d coins): cure all afflictions + Blessed") % cost, "disabled": Game.gold < cost},
		{"text": Loc.t("Blood sacrifice (-15 HP): ATK +1 permanent"), "disabled": Game.hp <= 16},
		{"text": Loc.t("Gamble (10 coins): 45% chance for 30 coins"), "disabled": Game.gold < 10},
		Loc.t("Leave"),
	]
	var c: int = await b.dialog.ask(Loc.t(name_).to_upper(), Loc.t("Candles burn with no one lighting them. Something watches from behind the altar."), opts, _icon("shrine"))
	match c:
		0:
			Game.change_gold(-cost)
			for s in Game.statuses.keys():
				if DB.STATUS[s]["bad"] and s != "hunger":
					Game.statuses.erase(s)
			Game.add_status("blessed", 1, -1, 20)
			Game.update_mind_status()
			Game.emit_signal("status_changed")
			Sfx.play("heal")
			_clear(id)
			await b.dialog.info(Loc.t("PRAYER ANSWERED"), Loc.t("Warm light envelops you. All afflictions vanish.\nBlessed for 20 steps."), DB.status_icon("blessed"))
		1:
			Game.change_hp(-15)
			Game.base["atk"] = int(Game.base["atk"]) + 1
			Sfx.play("hit")
			_clear(id)
			await b.dialog.info(Loc.t("BLOOD PACT"), Loc.t("Your blood drips onto the altar and... absorbs. You feel stronger.\nATK +1 permanent."), DB.status_icon("bloodlust"))
		2:
			Game.change_gold(-10)
			Sfx.play("dice")
			await b.get_tree().create_timer(0.6).timeout
			if rng.randf() < 0.45:
				Game.change_gold(30)
				Sfx.play("coin")
				await b.dialog.info(Loc.t("WIN!"), Loc.t("The altar spits coins! +30 coins."), DB.item_icon("koin"))
			else:
				Sfx.play("whisper")
				Game.change_mind(-3)
				await b.dialog.info(Loc.t("LOST"), Loc.t("Your coins vanish. A chuckle echoes from the altar. (Mind -3)"), DB.icon("skull"))


func _warp(id: int) -> void:
	var to: int = Game.tile(id)["data"].get("to", -1)
	if to < 0:
		return
	var c: int = await b.dialog.ask(Loc.t("PORTAL"), Loc.t("A vortex of light swirls on the floor. Where does it lead?"), [Loc.t("Enter portal"), Loc.t("Ignore")], _icon("warp"))
	if c == 0:
		await b.teleport(to)
		_msg(Loc.t("Thrown to another part of the maze!"), Color("#62c8b8"))


# =============================================================== mystery events
func _event(id: int) -> void:
	var pool: Array = ["warung", "tas", "sumur", "anak", "cermin", "dukun", "kuis"]
	if Game.stage == 1:
		pool.append("gelandangan")
	elif Game.stage == 2:
		pool.append_array(["perjanjian", "jembatan"])
	elif Game.stage == 3:
		pool.append_array(["dinding", "klinik"])
	var ev_name: String = pool[rng.randi() % pool.size()]
	call("_ev_" + ev_name)
	_clear(id)


func _ev_warung() -> void:
	var c: int = await b.dialog.ask(Loc.t("MYSTERIOUS STALL"), Loc.t("A dilapidated stall under dim lighting. A rice pack rests on the table with a note: [i]\"Pay what you will.\"[/i]"),
		[Loc.t("Pay 10 coins, take the rice"), Loc.t("Take it without paying (Satiety +55, Mind -8)"), Loc.t("Leave")], _icon("event"))
	if c == 0:
		if Game.gold >= 10:
			Game.change_gold(-10)
			Game.add_item("nasi")
			Game.change_mind(6)
			await b.dialog.info(Loc.t("HONEST"), Loc.t("Your honesty brings peace. +Rice Pack, Mind +6."), DB.item_icon("nasi"))
		else:
			Game.change_mind(-4)
	elif c == 1:
		Game.add_item("nasi")
		Game.change_hunger(55)
		Game.change_mind(-8)
		if rng.randf() < 0.4:
			Game.add_status("fear", 1)
			await b.dialog.info("...", Loc.t("You take the rice. From behind the curtain, two red eyes watch you.\nSomething is following you now."), DB.status_icon("fear"))
		else:
			await b.dialog.info(Loc.t("LUCKY?"), Loc.t("Nobody saw. +Rice Pack."), DB.item_icon("nasi"))


func _ev_tas() -> void:
	var c: int = await b.dialog.ask(Loc.t("ABANDONED BAG"), Loc.t("Someone lies motionless next to a backpack. Flies buzz above."),
		[Loc.t("Search the bag (risk infection)"), Loc.t("Pray for them (Mind +8)"), Loc.t("Leave")], _icon("event"))
	if c == 0:
		var items: Array = [["perban", "obat_merah", "kain", "roti"][rng.randi() % 4]]
		if rng.randf() < 0.3:
			items.append("dadu_emas")
		_give(items, 0)
		var extra := ""
		if rng.randf() < 0.45:
			Game.add_status("infect", 1)
			extra = "\n[color=#e85a42]" + Loc.t("Your hand scratches against something rusty inside... Infection.") + "[/color]"
		await b.dialog.info(Loc.t("BAG CONTENTS"), Loc.t("You found: %s") % _loot_text(items, 0) + extra, DB.item_icon(items[0]))
	elif c == 1:
		Game.change_mind(8)
		await b.dialog.info(Loc.t("PEACE"), Loc.t("You closed your eyes for them. Your heart feels lighter. (Mind +8)"), DB.status_icon("blessed"))


func _ev_sumur() -> void:
	var c: int = await b.dialog.ask(Loc.t("WHISPERING WELL"), Loc.t("From the old well, a voice whispers your name. \"%s... %s...\"") % [Game.player_name, Game.player_name],
		[Loc.t("Toss 5 coins"), Loc.t("Look inside (Mind -10, learn whole map)"), Loc.t("Leave")], _icon("event"))
	if c == 0:
		if Game.gold >= 5:
			Game.change_gold(-5)
			var r := rng.randf()
			if r < 0.3:
				var it: String = ["air_suci", "batu_jiwa", "jimat_kertas"][rng.randi() % 3]
				Game.add_item(it)
				await b.dialog.info(Loc.t("SOMETHING SHINY"), Loc.t("At the bottom of the well, %s is caught on the bucket rope!") % DB.item_name(it), DB.item_icon(it))
			elif r < 0.5:
				Game.change_mind(-15)
				Game.add_status("blind", 1, -1, 10)
				await b.dialog.info(Loc.t("DON'T LOOK BACK"), Loc.t("A pale face emerges from the water and stares into your eyes.\nMind -15, Blind for a while."), DB.status_icon("blind"))
			elif r < 0.8:
				Game.add_status("blessed", 1, -1, 15)
				await b.dialog.info(Loc.t("BLESSING"), Loc.t("The well water glows gently. Blessed for 15 steps."), DB.status_icon("blessed"))
			else:
				await b.dialog.info(Loc.t("PLOP"), Loc.t("Your coins sink into the water. Nothing happens."), DB.item_icon("koin"))
	elif c == 1:
		Game.change_mind(-10)
		b.reveal_all_tiles()


func _ev_anak() -> void:
	var c: int = await b.dialog.ask(Loc.t("CRYING CHILD"), Loc.t("At the end of a dark alley, a small child cries with their back turned."),
		[Loc.t("Approach and comfort"), Loc.t("Leave")], _icon("event"))
	if c == 1:
		Game.change_mind(-5)
		await b.dialog.info("...", Loc.t("The crying echoes in your head for hours. (Mind -5)"), DB.status_icon("fear"))
		return
	if rng.randf() < 0.65:
		Game.add_item("permen", 2)
		Game.change_mind(10)
		Game.gain_exp(8)
		await b.dialog.info(Loc.t("LOST CHILD"), Loc.t("They were lost looking for their mother. You guide them to a post. They give you 2 Candies. Mind +10, EXP +8."), DB.item_icon("permen"))
	else:
		Game.change_mind(-12)
		Game.add_status("fear", 1)
		Sfx.play("whisper")
		await b.dialog.info(Loc.t("NOT A CHILD"), Loc.t("Its head turns 180 degrees. Its face... has no face.\nMind -12, Fear."), DB.status_icon("fear"))


func _ev_cermin() -> void:
	var c: int = await b.dialog.ask(Loc.t("CRACKED MIRROR"), Loc.t("A tall mirror stands alone. Your reflection smiles... you do not."),
		[Loc.t("Touch the mirror"), Loc.t("Smash the mirror"), Loc.t("Leave")], _icon("event"))
	match c:
		0:
			var r := rng.randf()
			if r < 0.35:
				b.reveal_all_tiles()
				await b.dialog.info(Loc.t("VISION"), Loc.t("Your reflection points into the distance. Suddenly you see the entire labyrinth!"), DB.tile_icon("warp"))
			elif r < 0.7:
				Game.base["luck"] = int(Game.base["luck"]) + 1
				await b.dialog.info(Loc.t("LUCK"), Loc.t("Your reflection winks. You feel lucky. LUCK +1 permanent."), DB.icon("luck"))
			else:
				Game.change_mind(-20)
				Game.add_status("insane", 1)
				await b.dialog.info(Loc.t("THAT WAS NOT YOU"), Loc.t("Your reflection steps out of the mirror and walks away... in the opposite direction. (Mind -20)"), DB.status_icon("insane"))
		1:
			Game.change_hp(-6)
			Game.add_status("bleed")
			Game.add_item("batu_jiwa")
			Sfx.play("hit_heavy")
			await b.dialog.info(Loc.t("CRASH!"), Loc.t("Glass shards cut your hands (Bleeding). Behind the glass lies a Soul Stone."), DB.item_icon("batu_jiwa"))


func _ev_dukun() -> void:
	var cost := 35 * Game.stage
	var c: int = await b.dialog.ask(Loc.t("SHADY SHAMAN"), Loc.t("An old man in black sits cross-legged. \"Your body is stained, child. Care to be cleansed?\""),
		[{"text": Loc.t("Cleanse all diseases (%d coins)") % cost, "disabled": Game.gold < cost}, {"text": Loc.t("Buy Talisman (25 coins)"), "disabled": Game.gold < 25}, Loc.t("Leave")], _icon("event"))
	match c:
		0:
			Game.change_gold(-cost)
			for s in ["infect", "parasite", "poison", "toxic", "tumor", "curse"]:
				Game.remove_status(s)
			Sfx.play("heal")
			await b.dialog.info(Loc.t("CLEANSED"), Loc.t("He blows on your crown three times. All your ailments vanish."), DB.status_icon("regen"))
		1:
			Game.change_gold(-25)
			Game.add_item("jimat_kertas")
			await b.dialog.info(Loc.t("TALISMAN"), Loc.t("He writes with your blood on yellow paper. +Paper Talisman."), DB.item_icon("jimat_kertas"))


const QUIZ_EN := [
	["What is 7 x 8?", ["54", "56", "64"], 1],
	["Closest planet to the Sun?", ["Venus", "Mars", "Mercury"], 2],
	["Organ that pumps blood through the entire body?", ["Lungs", "Heart", "Liver"], 1],
	["H2O is the chemical formula for...", ["Salt", "Water", "Oxygen"], 1],
	["How many sides does a hexagon have?", ["5", "6", "8"], 1],
	["Blood cells that fight infection are...", ["White blood cells", "Red blood cells", "Platelets"], 0],
	["Plants produce food through...", ["Respiration", "Photosynthesis", "Evaporation"], 1],
	["Square root of 144 is...", ["12", "14", "16"], 0],
]

const QUIZ_ID := [
	["Berapa hasil 7 x 8?", ["54", "56", "64"], 1],
	["Planet terdekat dengan Matahari?", ["Venus", "Mars", "Merkurius"], 2],
	["Organ yang memompa darah ke seluruh tubuh?", ["Paru-paru", "Jantung", "Hati"], 1],
	["H2O adalah rumus kimia dari...", ["Garam", "Air", "Oksigen"], 1],
	["Berapa sisi yang dimiliki segi enam?", ["5", "6", "8"], 1],
	["Sel darah yang melawan infeksi adalah...", ["Sel darah putih", "Sel darah merah", "Keping darah"], 0],
	["Tumbuhan membuat makanan melalui proses...", ["Respirasi", "Fotosintesis", "Evaporasi"], 1],
	["Akar kuadrat dari 144 adalah...", ["12", "14", "16"], 0],
]


func _ev_kuis() -> void:
	var q_list := QUIZ_ID if Loc.lang == "id" else QUIZ_EN
	var q: Array = q_list[rng.randi() % q_list.size()]
	var c: int = await b.dialog.ask(Loc.t("RIDDLE MASTER"), Loc.t("A masked figure blocks the way. \"Answer correctly, and you may pass with a prize. Wrong... and you pay.\"\n\n[color=#ffd86a]%s[/color]") % q[0],
		q[1], _icon("event"))
	if c == int(q[2]):
		var g := 15 * Game.stage
		Game.change_gold(g)
		Game.gain_exp(10 * Game.stage)
		Game.change_mind(8)
		Sfx.play("levelup")
		await b.dialog.info(Loc.t("CORRECT!"), Loc.t("\"Clever...\" The figure fades away. +%d coins, EXP +%d, Mind +8.") % [g, 10 * Game.stage], DB.icon("exp"))
	else:
		Game.change_mind(-10)
		Game.change_hp(-6)
		Sfx.play("error")
		await b.dialog.info(Loc.t("WRONG!"), Loc.t("Correct answer was: %s.\nThe mask cracks into a smile. Mind -10, HP -6.") % q[1][int(q[2])], DB.icon("skull"))


func _ev_gelandangan() -> void:
	var has_food := Game.count("roti") > 0 or Game.count("nasi") > 0
	var c: int = await b.dialog.ask(Loc.t("BEGGAR"), Loc.t("A frail old man shivers on the ground. \"Child... got any food?\""),
		[{"text": Loc.t("Give Food (-1 food item)"), "disabled": not has_food}, {"text": Loc.t("Give 10 coins"), "disabled": Game.gold < 10}, Loc.t("Leave")], _icon("event"))
	match c:
		0:
			if Game.count("roti") > 0:
				Game.remove_item("roti")
			else:
				Game.remove_item("nasi")
			Game.change_mind(15)
			Game.add_item("x_kacamata")
			await b.dialog.info(Loc.t("THANK YOU"), Loc.t("\"Take these, child. My old glasses. You will see what cannot be seen.\"\n+Glasses, Mind +15."), DB.item_icon("x_kacamata"))
		1:
			Game.change_gold(-10)
			Game.change_mind(10)
			Game.add_status("blessed", 1, -1, 10)
			await b.dialog.info(Loc.t("PRAYER"), Loc.t("He prays for you earnestly. Mind +10, Blessed."), DB.status_icon("blessed"))


func _ev_perjanjian() -> void:
	var c: int = await b.dialog.ask(Loc.t("DEVIL'S DEAL"), Loc.t("A demon in a business suit emerges from smoke. \"I offer the finest weapon... for a tiny piece of your soul. Just 15 Max HP. Forever.\""),
		[Loc.t("Accept (Max HP -15, get Hell Trident)"), Loc.t("Decline")], DB.enemy_tex("iblis"), "PanelRed")
	if c == 0:
		Game.base["hp"] = int(Game.base["hp"]) - 15
		Game.hp = mini(Game.hp, Game.max_hp())
		Game.add_item("w_trisula")
		Sfx.play("magic")
		await b.dialog.info(Loc.t("CONTRACT SIGNED"), Loc.t("A chill spreads through your chest. +Hell Trident. Max HP -15."), DB.item_icon("w_trisula"))
	else:
		Game.change_mind(5)
		_msg(Loc.t("The demon sneers and dissipates."), Game.C_INFO)


func _ev_jembatan() -> void:
	var c: int = await b.dialog.ask(Loc.t("FRAGILE BRIDGE"), Loc.t("A bridge made of bones crosses a river of lava. On the other side lies a gleaming bag."),
		[Loc.t("Cross (dice 3+)"), Loc.t("Leave")], _icon("event"))
	if c != 0:
		return
	var roll := rng.randi_range(1, 6) + (1 if Game.agi() >= 7 else 0)
	Sfx.play("dice_land")
	if roll >= 3 and not Game.has("frac_leg"):
		var g := rng.randi_range(40, 70)
		Game.change_gold(g)
		Game.add_item("tanduk")
		Sfx.play("coin")
		await b.dialog.info(Loc.t("SUCCESS (roll %d)") % roll, Loc.t("You made it across safely. +%d coins, +Demon Horn.") % g, DB.item_icon("kantong"))
	else:
		Game.change_hp(-14)
		Game.add_status("burn", 1, 3)
		Game.add_status("frac_leg")
		Sfx.play("hit_heavy")
		await b.dialog.info(Loc.t("FELL! (roll %d)") % roll, Loc.t("The bone bridge snaps! Your legs plunge into lava.\n-14 HP, Broken Leg."), DB.status_icon("burn"))


func _ev_dinding() -> void:
	var c: int = await b.dialog.ask(Loc.t("FLESH WALL"), Loc.t("A pulsating wall obstructs the path. Inside something glimmers... and moves."),
		[Loc.t("Tear with bare hands (Bleeding)"), {"text": Loc.t("Burn with Molotov (-1 Molotov)"), "disabled": Game.count("molotov") <= 0}, Loc.t("Leave")], _icon("event"))
	match c:
		0:
			Game.add_status("bleed")
			Game.add_item("daging_tumor", 2)
			var g := rng.randi_range(30, 60)
			Game.change_gold(g)
			await b.dialog.info(Loc.t("SUCCESS... DISGUSTING"), Loc.t("You tore through the flesh. +2 Tumor Meat, +%d coins.") % g, DB.item_icon("daging_tumor"))
		1:
			Game.remove_item("molotov")
			Game.add_item("daging_tumor", 2)
			var g2 := rng.randi_range(35, 65)
			Game.change_gold(g2)
			Sfx.play("fire")
			await b.dialog.info(Loc.t("SUCCESS... DISGUSTING"), Loc.t("You tore through the flesh. +2 Tumor Meat, +%d coins.") % g2, DB.item_icon("daging_tumor"))


func _ev_klinik() -> void:
	var c: int = await b.dialog.ask(Loc.t("DERELICT CLINIC"), Loc.t("A rusted medicine cabinet. The labels are unreadable. Breaths come from behind the curtain."),
		[Loc.t("Rummage through the cabinet"), Loc.t("Open the curtain"), Loc.t("Leave")], _icon("event"))
	match c:
		0:
			if rng.randf() < 0.6:
				Game.add_item("obat_merah")
				Game.add_item("perban")
				await b.dialog.info(Loc.t("MEDICINE!"), Loc.t("+Antiseptic, +Bandage."), DB.item_icon("obat_merah"))
			else:
				Game.add_status("toxic")
				await b.dialog.info(Loc.t("NEEDLE!"), Loc.t("A used syringe pricks your finger. Toxic Poison."), DB.status_icon("toxic"))
		1:
			if rng.randf() < 0.5:
				Game.heal(30)
				Game.remove_status("infect")
				await b.dialog.info(Loc.t("THE LAST PATIENT"), Loc.t("An elderly nurse smiles, then silently treats your wounds. +30 HP, Infection cured."), DB.status_icon("regen"))
			else:
				Sfx.play("growl", 0.0)
				await b.dialog.info(Loc.t("NOT A PATIENT"), Loc.t("The one lying there rises with a scalpel in hand!"), DB.enemy_tex("bedah"), Loc.t("Fight!"))
				await start_battle(["daging"], -1, "ambush")
