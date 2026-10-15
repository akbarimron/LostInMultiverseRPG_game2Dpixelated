class_name GuideBook
extends Control
## In-game Guide Book. Content is generated dynamically and fully supports English and Bahasa Indonesia.
## Usage: var gb := GuideBook.new(); layer.add_child(gb); await gb.closed

signal closed

const G := "res://assets/gen/"
const CHAPTERS := [
	["welcome", "Welcome"],
	["controls", "Controls"],
	["board", "The Board"],
	["tiles", "Tile Types"],
	["combat", "Combat"],
	["parts", "Body Parts"],
	["parry", "Parry"],
	["conditions", "Conditions"],
	["survival", "Hunger, Mind, Phobia"],
	["items", "Items"],
	["gear", "Equipment"],
	["crafting", "Crafting"],
	["skills", "Skills"],
	["bestiary", "Bestiary"],
	["stages", "Stages"],
	["tips", "Survival Tips"],
]

var chapter_box: VBoxContainer
var page: RichTextLabel
var page_title: Label
var _buttons := {}
var _current := ""
var start_chapter := "welcome"


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	add_child(UI.dim_bg())
	var root := UI.panel()
	root.position = Vector2(10, 8)
	root.size = Vector2(620, 344)
	add_child(root)
	var v := UI.vbox(4)
	root.add_child(v)
	var head := UI.hbox(6)
	v.add_child(head)
	head.add_child(UI.icon_rect(DB.icon("exp")))
	head.add_child(UI.label(Loc.t("GUIDE BOOK"), Color(), "TitleLabel"))
	head.add_child(UI.label("• Lost in Multiverse", Color(), "DimLabel"))
	head.add_child(UI.spacer(0, 0, true))
	head.add_child(UI.label(Loc.t("[↑↓] chapter  [Esc] close"), Color(), "DimLabel"))
	head.add_child(UI.button(Loc.t("Close"), _close))
	v.add_child(HSeparator.new())
	var body := UI.hbox(6)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(body)
	var left := UI.panel("PanelDark")
	left.custom_minimum_size = Vector2(132, 0)
	body.add_child(left)
	var ls := ScrollContainer.new()
	ls.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(ls)
	chapter_box = UI.vbox(0)
	chapter_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ls.add_child(chapter_box)
	for ch in CHAPTERS:
		var key: String = ch[0]
		var b := Button.new()
		b.theme_type_variation = "ListButton"
		b.text = Loc.t(ch[1])
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.pressed.connect(func(): show_chapter(key))
		chapter_box.add_child(b)
		_buttons[key] = b
	var right := UI.panel("PanelDark")
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var rv := UI.vbox(3)
	right.add_child(rv)
	page_title = UI.label("", Color("#ffd86a"))
	rv.add_child(page_title)
	page = UI.rich("", false)
	page.custom_minimum_size = Vector2(450, 284)
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.scroll_active = true
	page.selection_enabled = false
	rv.add_child(page)
	Loc.language_changed.connect(_on_lang_changed)
	show_chapter(start_chapter)
	Sfx.play("open", 0.05, -6)


func _on_lang_changed(_l: String) -> void:
	for ch in CHAPTERS:
		var key: String = ch[0]
		if _buttons.has(key):
			_buttons[key].text = Loc.t(ch[1])
	show_chapter(_current)


func _close() -> void:
	Sfx.play("cancel")
	closed.emit()
	queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var keys: Array = []
	for ch in CHAPTERS:
		keys.append(ch[0])
	var i := keys.find(_current)
	match event.keycode:
		KEY_ESCAPE, KEY_G:
			_close()
		KEY_DOWN, KEY_S:
			show_chapter(keys[mini(i + 1, keys.size() - 1)])
		KEY_UP, KEY_W:
			show_chapter(keys[maxi(i - 1, 0)])
		KEY_PAGEDOWN:
			page.get_v_scroll_bar().value += 120
		KEY_PAGEUP:
			page.get_v_scroll_bar().value -= 120
	get_viewport().set_input_as_handled()


func show_chapter(key: String) -> void:
	_current = key
	for k in _buttons:
		_buttons[k].button_pressed = (k == key)
	for ch in CHAPTERS:
		if ch[0] == key:
			page_title.text = Loc.t(ch[1]).to_upper()
	page.text = call("_ch_" + key)
	page.scroll_to_line(0)
	Sfx.play("move", 0.05, -8)


# ---------------------------------------------------------------- helpers
static func img(path: String, size_px: int = 0) -> String:
	if size_px > 0:
		return "[img=%dx%d]%s[/img]" % [size_px, size_px, path]
	return "[img]%s[/img]" % path


static func h(t: String) -> String:
	return "[color=#ffd86a]%s[/color]" % t


static func dim(t: String) -> String:
	return "[color=#a89ab8]%s[/color]" % t


static func good(t: String) -> String:
	return "[color=#7ec45c]%s[/color]" % t


static func bad(t: String) -> String:
	return "[color=#e85a42]%s[/color]" % t


# ---------------------------------------------------------------- chapters
func _ch_welcome() -> String:
	if Loc.lang == "id":
		return "%s\n\n" % img(G + "chars/player_front.png", 64) + \
			"Kamu adalah seorang anak SMA yang pulang kemalaman. Di tengah jalan pulang, kotamu tiba-tiba melipat diri menjadi sebuah %s, " % h("labirin misterius") + \
			"dan setiap gerbang yang kamu lewati membawamu ke tempat yang kian mengerikan: dari %s, ke %s, hingga %s yang hidup berdenyut.\n\n" % [h(DB.stage_name(1)), h(DB.stage_name(2)), h(DB.stage_name(3))] + \
			"%s Capai %s di ujung labirin dan kalahkan penjaganya. Taklukkan ketiga dimensi untuk terbangun kembali di duniamu.\n\n" % [h("TUJUAN:"), h("Gerbang Boss")] + \
			"Cara Bermain: Permainan ini mengadopsi mekanisme papan RPG & survival: %s, berjalan kotak demi kotak di papan, dan hadapi peristiwa apa pun yang menunggumu di kotak tempatmu mendarat. " % h("lempar dadu") + \
			"Pertarungan berjalan turn-based. Luka, patah tulang, infeksi, lapar, dan ketakutan %s, jadi rawatlah tubuh dan pikiranmu dengan baik.\n\n" % bad("terus menumpuk") + \
			dim("Tip: Buka buku panduan ini kapan saja dengan menekan [G], dari menu jeda [Esc], atau dari tombol Panduan saat bertarung.") + \
			"\n\n[color=#8a7e96](c) 2026 Developer @Hibareit • Instagram: @akbar_diy[/color]"
	return "%s\n\n" % img(G + "chars/player_front.png", 64) + \
		"You are a high-school student who stayed out too late. On the way home the city folded into a %s, " % h("labyrinth") + \
		"and every gate you open leads somewhere worse: from %s, to the %s, to the living %s.\n\n" % [h("Grim City"), h("Dimension of Darkness"), h("Tumor Dimension")] + \
		"%s Reach the %s at the end of each labyrinth and defeat its guardian. Beat all three to wake up.\n\n" % [h("GOAL:"), h("Boss Gate")] + \
		"The game plays like a board game: %s, walk tile by tile, and deal with whatever is waiting on the tile you land on. " % h("roll a die") + \
		"Fights are turn-based. Wounds, broken bones, infections, hunger and fear %s, so take care of your body and your mind.\n\n" % bad("stack up") + \
		dim("Tip: open this book any time with [G], from the pause menu, or with the Guide command in battle.") + \
		"\n\n[color=#8a7e96](c) 2026 Developer @Hibareit • Instagram: @akbar_diy[/color]"


func _ch_controls() -> String:
	var rows: Array = []
	if Loc.lang == "id":
		rows = [
			["Spasi / Enter", "Lempar dadu, konfirmasi pilihan, PARRY saat musuh menyerang"],
			["Panah / WASD", "Pilih arah di persimpangan jalan (atau klik kotak tujuan)"],
			["Mouse", "Klik tombol, kotak, musuh; arahkan kursor untuk melihat info"],
			["I / Tab", "Buka tas, perlengkapan, racikan, kondisi & skill"],
			["M", "Buka peta lengkap labirin beserta legendanya (atau klik peta mini)"],
			["G", "Buka Buku Panduan ini kapan saja"],
			["C", "Saat bertarung: lihat semua buff & debuff (kamu dan musuh)"],
			["Esc", "Menu jeda / kembali / tutup jendela popup"],
			["1 - 9", "Pilih cepat opsi pilihan menu"],
			["Klik Kanan / Esc", "Kembali dari sub-menu saat pertarungan"],
		]
	else:
		rows = [
			["Space / Enter", "Roll the die, confirm, PARRY when an enemy attacks"],
			["Arrows / WASD", "Choose a direction at a junction (or click the tile)"],
			["Mouse", "Click buttons, tiles, enemies; hover for tooltips"],
			["I / Tab", "Bag, equipment, crafting, condition, skills"],
			["M", "Full map with legend (or click the minimap)"],
			["G", "Open this Guide Book"],
			["C", "In battle: see every buff & debuff (you and the enemies)"],
			["Esc", "Pause menu / go back / close windows"],
			["1 - 9", "Quick-pick a menu option"],
			["Right click / Esc", "Back out of a battle sub-menu"],
		]
	var s := "[table=2]"
	for r in rows:
		s += "[cell]%s  [/cell][cell]%s[/cell]" % [h(r[0]), r[1]]
	return s + "[/table]"


func _ch_board() -> String:
	if Loc.lang == "id":
		return "%s Tekan %s. Kamu akan berjalan sejumlah kotak sesuai angka dadu, satu per satu.\n\n" % [h("Melempar Dadu."), h("Spasi")] + \
			"%s Di persimpangan jalan, panah kuning akan muncul. Pilih arah menggunakan tombol panah/WASD atau klik kotak bercahaya. " % h("Persimpangan.") + \
			"Kamu tidak bisa berbalik ke arah yang baru saja kamu lalui, kecuali di jalan buntu di mana kamu akan berbalik. Jalan buntu sering kali menyembunyikan %s.\n\n" % h("harta karun") + \
			"%s Kotak yang belum dijelajahi tertutup kabut (?). Kotak akan terbuka dalam jarak 2 langkah dari posisimu. " % h("Kabut (Fog of War).") + \
			"Kondisi %s mempersempit pandanganmu hanya sampai petak di sebelahmu dan membuat petamu buram (petak yang sudah dijelajah tetap terlihat).\n\n" % bad("Buta") + \
			"%s %s selalu menghentikan langkahmu, meskipun dadumu masih memiliki sisa langkah.\n\n" % [h("Gerbang Boss."), h("Gerbang Boss")] + \
			"%s Setiap langkah mengurangi tingkat kekenyangan (Lapar). Pendarahan, racun, infeksi, dan tumor juga berdetak di setiap langkah.\n\n" % h("Biaya Langkah.") + \
			"%s %s memodifikasi lemparan dadumu: Sepatu Lari +1, Kaki Patah -2, Lapar IV -1, Kutukan bisa memaksanya bernilai 1. %s memungkinkanmu memilih angka sesukamu (1-6).\n\n" % [h("Pengubah Dadu."), "Beberapa efek", h("Dadu Emas")] + \
			"%s Permainan otomatis tersimpan (autosave) setiap kali kamu siap melempar dadu. Kematian memungkinkanmu mengulang stage dari awal." % h("Penyimpanan.")
	return "%s Press %s. You walk that many tiles, one at a time.\n\n" % [h("Rolling."), h("Space")] + \
		"%s At a crossroads, yellow arrows appear. Pick a way with the arrow keys or by clicking a highlighted tile. " % h("Junctions.") + \
		"You can't turn back the way you just came, except at a dead end, where you bounce back. Dead ends often hide %s.\n\n" % h("treasure") + \
		"%s Unexplored tiles are covered by fog (?). You reveal tiles within 2 steps of where you've been. " % h("Fog.") + \
		"Being %s shrinks your sight to the tiles right next to you and blurs your map (explored tiles stay visible).\n\n" % bad("Blind") + \
		"%s The %s always stops you, even if you have steps left.\n\n" % [h("Boss Gate."), h("Boss Gate")] + \
		"%s Every step drains your food. Bleeding, poison, infection and tumors also tick on every step.\n\n" % h("Steps cost.") + \
		"%s %s modify your roll: Running Shoes +1, Broken Leg -2, Hunger IV -1, Curse may turn it into a 1. The %s lets you choose the number.\n\n" % [h("Dice modifiers."), "Some effects", h("Golden Die")] + \
		"%s The game autosaves whenever you can roll. Dying lets you retry the current stage from its start." % h("Saving.")


func _ch_tiles() -> String:
	var s := "[table=2]"
	for k in ["start", "enemy", "elite", "boss", "treasure", "item", "merchant", "trap", "event", "rest", "shrine", "warp"]:
		var info: Dictionary = DB.TILE_INFO[k]
		var tname: String = DB.tile_name(k)
		s += "[cell]%s  [/cell][cell][color=#%s]%s[/color]\n%s\n[/cell]" % [img(G + "tiles/icon_%s.png" % k), info["color"].to_html(false), tname, dim(_tile_detail(k))]
	return s + "[/table]"


func _tile_detail(k: String) -> String:
	if Loc.lang == "id":
		return {
			"start": "Titik awal kamu memulai stage ini.",
			"enemy": "1-3 musuh biasa. Semakin dalam labirin, semakin banyak gerombolan musuh.",
			"elite": "Musuh tangguh berhadiah barang langka. Terkadang membawa bantuan.",
			"boss": "Penjaga dimensi labirin. Tak bisa kabur begitu pertarungan dimulai. Kamu bisa mundur sebelum masuk.",
			"treasure": "Emas & perlengkapan. Beberapa terkunci (pakai Kunci Tua, congkel, atau hancurkan). Hati-hati Peti Mimik!",
			"item": "Item konsumsi atau bahan racikan gratis.",
			"merchant": "Beli perlengkapan dan obat, jual barang apa pun dengan setengah harga. Dagangan berganti tiap stage.",
			"trap": "Lompati (cek dadu) atau ganjal dengan Besi Bekas. Separuh jebakan tersembunyi dan bisa menyergap saat lewat. Kacamata membongkarnya.",
			"event": "Peristiwa acak dengan pilihan taruhan: dukun misterius, cermin terkutuk, teka-teki, hantu gentayangan...",
			"rest": "Tidur, rawat luka, atau masak. Sekali pakai. Hati-hati disergap musuh saat tidur!",
			"shrine": "Berdoa untuk sembuhkan semua penyakit, korbankan darah demi ATK permanen, atau judi koin emas.",
			"warp": "Menteleportasimu ke portal pasangannya di sudut labirin lain (mulai stage 2).",
		}.get(k, "")
	return {
		"start": "Your starting point for the stage.",
		"enemy": "1-3 ordinary enemies. Deeper in the maze, bigger groups.",
		"elite": "A tough enemy with great loot. Sometimes with backup.",
		"boss": "The stage guardian. No escape once the fight starts. You may step back first.",
		"treasure": "Gold + gear. Some are locked (use an Old Key, pick it, or smash it). Some are MIMICS.",
		"item": "Free consumables or crafting materials.",
		"merchant": "Buy gear and medicine, sell anything for half price. Stock changes per stage.",
		"trap": "Jump over it (dice check) or jam it with Scrap Iron. Half of all traps are HIDDEN and can even snap shut when you walk past. Glasses reveal them.",
		"event": "A random encounter with choices: shady shops, cursed mirrors, riddles, ghosts...",
		"rest": "Sleep, treat wounds or cook. One use. Sleeping may get you ambushed.",
		"shrine": "Pray to cure everything, give blood for permanent ATK, or gamble coins.",
		"warp": "Teleports you to its twin portal somewhere else in the maze (stage 2+).",
	}.get(k, "")


func _ch_combat() -> String:
	if Loc.lang == "id":
		return "Pertarungan berbasis giliran (turn-based): %s, lalu semua musuh bertindak, kemudian luka dan racun berdetak.\n\n" % h("kamu bertindak duluan") + \
			"[table=2]" + \
			"[cell]%s  [/cell][cell]Pilih musuh, lalu pilih %s. Senjata menentukan damage, akurasi, dan efek status (pendarahan, patah tulang, bakar, stun).[/cell]" % [img(G + "icons/atk.png"), h("bagian tubuh")] + \
			"[cell]%s  [/cell][cell]%s: damage diterima -50%%, zona parry jauh lebih lebar, Mind +5.[/cell]" % [img(G + "icons/def.png"), h("Bertahan (Defend)")] + \
			"[cell]%s  [/cell][cell]%s: jurus khusus yang memakai Mind. Skill baru terbuka saat naik level.[/cell]" % [img(G + "icons/mind.png"), h("Skill")] + \
			"[cell]%s  [/cell][cell]%s: sembuhkan luka, obati status, atau lempar barang (Batu, Molotov, Garam).[/cell]" % [img(G + "items/kantong.png"), h("Item")] + \
			"[cell]%s  [/cell][cell]%s: peluang kabur bergantung AGI milikmu vs musuh. Mustahil kabur dari Boss atau saat Kaki Patah. Bom Asap dijamin 100%% berhasil.[/cell]" % [img(G + "icons/agi.png"), h("Kabur (Flee)")] + \
			"[cell]%s  [/cell][cell]%s: periksa status dan buff/debuff pada dirimu dan musuh. Tidak menghabiskan giliran.[/cell]" % [img(G + "icons/skull.png"), h("Cek (Check)")] + \
			"[/table]\n" + \
			"%s Sergapan membuat musuh bertindak duluan. Petarung yang pingsan (Stun) atau ketakutan kehilangan gilirannya.\n" % h("Urutan Giliran.") + \
			"%s Peluang kritikal = 5%% + LUCK + bonus senjata. Menghasilkan damage x1.75.\n" % h("Serangan Kritis.") + \
			"%s %s (kiri atas layar tarung) mencatat semua efek yang memengaruhimu beserta sisa durasinya. Ikon di atas musuh menunjukkan status mereka; arahkan mouse untuk melihat rinciannya.\n" % [h("Panel Kondisi."), h("KONDISI")] + \
			"%s Menangkan pertarungan untuk mendapat EXP, koin, dan barang. Pencuri yang tewas akan menjatuhkan kembali barang yang dicuri. Naik level memulihkan penuh HP dan Mind." % h("Hadiah.")
	return "Battles are turn-based: %s, then every enemy acts, then wounds and effects tick.\n\n" % h("you act first") + \
		"[table=2]" + \
		"[cell]%s  [/cell][cell]Choose an enemy, then a %s. Weapon decides damage, accuracy and special effects (bleed, break, burn, stun).[/cell]" % [img(G + "icons/atk.png"), h("body part")] + \
		"[cell]%s  [/cell][cell]%s: damage taken -50%%, much wider parry zone, Mind +5.[/cell]" % [img(G + "icons/def.png"), h("Defend")] + \
		"[cell]%s  [/cell][cell]%s: special moves that cost Mind. New skills unlock as you level up.[/cell]" % [img(G + "icons/mind.png"), h("Skill")] + \
		"[cell]%s  [/cell][cell]%s: heal, cure, or throw things (Rock, Molotov, Salt).[/cell]" % [img(G + "items/kantong.png"), h("Item")] + \
		"[cell]%s  [/cell][cell]%s: chance depends on your AGI vs theirs. Impossible vs bosses or with a Broken Leg. Smoke Bombs always work.[/cell]" % [img(G + "icons/agi.png"), h("Flee")] + \
		"[cell]%s  [/cell][cell]%s: look at every buff and debuff on you and on the enemies. Does not use your turn.[/cell]" % [img(G + "icons/skull.png"), h("Check")] + \
		"[/table]\n" + \
		"%s Ambushes let enemies act first. Stunned or terrified fighters lose their turn.\n" % h("Turn order.") + \
		"%s Your crit chance = 5%% + LUCK + weapon bonus. Crits deal x1.75.\n" % h("Criticals.") + \
		"%s %s (top-left of the battle screen) lists everything affecting you, with turns remaining. Icons over enemies show theirs; hover for details.\n" % [h("Conditions panel."), h("CONDITION")] + \
		"%s Win to earn EXP, coins and loot. Thieves who die drop what they stole. Level ups fully heal you." % h("Rewards.")


func _ch_parts() -> String:
	if Loc.lang == "id":
		var s := "Setiap musuh memiliki bagian tubuh dengan HP masing-masing. Serangan ke anggota tubuh merusak bagian tersebut secara penuh dan mengurangi HP tubuh utama sebagian. " + \
			"Membidik bagian kecil %s, namun jika berhasil dihancurkan memberikan efek krusial.\n\n" % bad("lebih sulit kena")
		s += "[table=2]"
		for k in ["main", "kill", "arm", "leg", "blind", "free", "stun"]:
			var names := []
			for kind in DB.PARTS:
				for p in DB.PARTS[kind]:
					var pname: String = DB.part_name(p)
					if p["brk"] == k and not names.has(pname):
						names.append(pname)
			s += "[cell]%s  [/cell][cell]%s\n%s\n[/cell]" % [h(", ".join(names)), DB.part_effect(k), ""]
		s += "[/table]"
		s += "\n%s Akurasi yang ditampilkan di menu target sudah memperhitungkan penalti ukuran bagian tubuh, AGI musuh, dan kebutaanmu. Kaki musuh yang patah membuatnya jauh lebih mudah diserang." % h("Akurasi.")
		return s
	var s := "Every enemy has body parts with their own HP. Hits on a limb damage that limb fully and the main body partly. " + \
		"Aiming at small parts is %s, but breaking them has big effects.\n\n" % bad("harder to hit")
	s += "[table=2]"
	for k in ["main", "kill", "arm", "leg", "blind", "free", "stun"]:
		var names := []
		for kind in DB.PARTS:
			for p in DB.PARTS[kind]:
				if p["brk"] == k and not names.has(DB.part_name(p)):
					names.append(DB.part_name(p))
		s += "[cell]%s  [/cell][cell]%s\n%s\n[/cell]" % [h(", ".join(names)), DB.PART_EFFECT[k], ""]
	s += "[/table]"
	s += "\n%s The hit chance shown in the part menu already includes the part penalty, the enemy's AGI and your blindness. A broken leg makes an enemy much easier to hit." % h("Accuracy.")
	return s


func _ch_parry() -> String:
	if Loc.lang == "id":
		return "Saat musuh melancarkan serangan, bilah %s muncul di bagian atas layar. Indikator bergerak dari kiri ke kanan.\n\n" % h("PARRY") + \
			"Tekan %s (atau klik) saat indikator berada tepat di dalam:\n" % h("Spasi / Enter / Z / X") + \
			"  %s  =  bebas damage, Mind +4, dan kamu langsung %s secara instan.\n" % [h("Zona Emas (SEMPURNA / PERFECT)"), good("SERANGAN BALAS")] + \
			"  %s  =  hanya terkena 30%% damage, dan peluang terkena efek buruk berkurang drastis.\n" % h("Zona Oranye (TAHAN / BLOCKED)") + \
			"  %s  =  terkena damage penuh dan risiko tinggi terkena status buruk.\n\n" % bad("Di Luar / Terlambat") + \
			"%s Posisi zona parry bergeser di tiap serangan. Musuh stage akhir dan boss bergerak lebih cepat.\n" % h("Catatan.") + \
			"Aksi Bertahan membuat kedua zona parry menjadi jauh lebih lebar. Status Fokus memperlebar zona emas. Ketakutan mengecilkan kedua zona. Kondisi Buta membuat indikator berkedip-kedip tak menentu.\n" + \
			"Karakter lincah (AGI tinggi) terkadang menghindar sebelum bilah parry sempat muncul. Serangan psikis (Mind) dan kutukan tidak dapat di-parry."
	return "When an enemy attacks, a %s appears at the top of the screen. A cursor sweeps from left to right.\n\n" % h("PARRY bar") + \
		"Press %s (or click) when the cursor is inside:\n" % h("Space / Enter / Z / X") + \
		"  %s  =  no damage, Mind +4, and you instantly %s.\n" % [h("Gold zone (PERFECT)"), good("counter-attack")] + \
		"  %s  =  only 30%% damage, and status effects are much less likely.\n" % h("Amber zone (BLOCKED)") + \
		"  %s  =  full damage and full chance of status effects.\n\n" % bad("Outside / too late") + \
		"%s The zones move every attack. Later stages and bosses are faster.\n" % h("Notes.") + \
		"Defend makes both zones much wider. Focus widens the gold zone. Fear shrinks them. Being Blind makes the cursor flicker.\n" + \
		"Agile characters sometimes dodge before the bar even appears. Mind attacks and curses cannot be parried."


func _ch_conditions() -> String:
	var prefix := "Kondisi bergaya Fear & Hunger. Sebagian besar status buruk %s jika diabaikan. Efek khusus tarung berakhir saat pertarungan usai; sisanya mengikuti ke papan permainan.\n\n" % bad("semakin parah") if Loc.lang == "id" else "Fear & Hunger style conditions. Most debuffs %s if ignored. Battle-only effects end when the fight ends; the rest follow you onto the board.\n\n" % bad("get worse")
	var s := prefix
	s += h(Loc.t("DEBUFFS")) + "\n[table=2]"
	for id in DB.STATUS:
		var st: Dictionary = DB.STATUS[id]
		if not st["bad"]:
			continue
		s += _status_cell(id, st)
	s += "[/table]\n" + h(Loc.t("BUFFS")) + "\n[table=2]"
	for id in DB.STATUS:
		var st2: Dictionary = DB.STATUS[id]
		if st2["bad"]:
			continue
		s += _status_cell(id, st2)
	return s + "[/table]"


func _status_cell(id: String, st: Dictionary) -> String:
	var is_id := (Loc.lang == "id")
	var name_col := "#e85a42" if st["bad"] else "#7ec45c"
	var lvl := (" (maks %s)" % DB.roman(int(st["max"]))) if int(st["max"]) > 1 else "" if is_id else ((" (max %s)" % DB.roman(int(st["max"]))) if int(st["max"]) > 1 else "")
	var scope := " [khusus tarung]" if id in DB.BATTLE_ONLY else "" if is_id else (" [battle only]" if id in DB.BATTLE_ONLY else "")
	var cause_lbl := "Penyebab:" if is_id else "Cause:"
	var cure_lbl := "Pengobatan:" if is_id else "Fix:"
	return "[cell]%s  [/cell][cell][color=%s]%s[/color]%s%s\n%s\n%s %s\n%s %s\n[/cell]" % [
		img(G + "status/%s.png" % id), name_col, DB.status_name(id), dim(lvl), dim(scope), DB.status_desc(id),
		dim(cause_lbl), DB.status_cause(id), dim(cure_lbl), DB.status_cure(id)]


func _ch_survival() -> String:
	if Loc.lang == "id":
		return "%s Kesehatan fisikmu. Jika 0 kamu mati. Max HP berkurang akibat Infeksi dan Kelaparan parah.\n\n" % h("HP (Darah)") + \
			"%s Kewarasan dan bahan bakar skill. Monster, bisikan gaib, dan pemandangan mengerikan mengurasnya. " % h("Mind (Pikiran)") + \
			"Di angka 0 kamu menjadi %s: mengalami halusinasi, nama musuh berubah aneh, angka damage menipumu, dan seranganmu bisa memukul teman atau dirimu sendiri. Pulihkan Mind di atas 20 untuk sembuh.\n\n" % bad("GILA (Madness)") + \
			"%s Tingkat kekenyangan perut (100 = kenyang penuh, 0 = kelaparan). Berkurang 1 poin setiap langkah (2 jika ada cacing parasit).\n" % h("Kekenyangan / Lapar") + \
			"[table=2][cell]%s  [/cell][cell]Kenyang 50-70  Lapar I: Max HP -5[/cell][cell]  [/cell][cell]Kenyang 30-50  Lapar II: Max HP -10, ATK -10%%[/cell][cell]  [/cell][cell]Kenyang 15-30  Lapar III: Max HP -20, ATK -20%%[/cell][cell]  [/cell][cell]Kenyang 1-15  Lapar IV: Max HP -30, dadu -1[/cell][cell]  [/cell][cell]Kenyang 0  Lapar V: KELAPARAN, kehilangan 3 HP tiap melangkah[/cell][/table]\n\n" % img(G + "status/hunger.png") + \
			"%s Setiap permainan baru memberimu fobia acak. Bertarung melawan musuh yang memicu fobiamu membuatmu %s:\n" % [h("Fobia Tersembunyi."), bad("ketakutan (Fear)")] + \
			_phobia_list() + "\n" + \
			"%s Setiap naik level: +9 Max HP, +5 Max Mind, kenaikan ATK/DEF/AGI, serta membuka skill baru pada Lv 2, 3, 4, 5, 6, dan 8." % h("Kenaikan Level.")
	return "%s Your body. At 0 you die. Max HP is lowered by Infection and Hunger.\n\n" % h("HP") + \
		"%s Your sanity and skill fuel. Monsters, whispers and horrible sights drain it. " % h("Mind") + \
		"At 0 you go %s: you hallucinate, enemy names and damage numbers lie, and your attacks may hit the wrong target or yourself. Get Mind back above 20 to recover.\n\n" % bad("MAD") + \
		"%s Satiety level (100 = full stomach, 0 = starving). Drains by 1 point every step (2 with parasites).\n" % h("Satiety / Hunger") + \
		"[table=2][cell]%s  [/cell][cell]Satiety 50-70  Hunger I: Max HP -5[/cell][cell]  [/cell][cell]Satiety 30-50  Hunger II: Max HP -10, ATK -10%%[/cell][cell]  [/cell][cell]Satiety 15-30  Hunger III: Max HP -20, ATK -20%%[/cell][cell]  [/cell][cell]Satiety 1-15  Hunger IV: Max HP -30, dice -1[/cell][cell]  [/cell][cell]Satiety 0  Hunger V: Starving, -3 HP every step[/cell][/table]\n\n" % img(G + "status/hunger.png") + \
		"%s Each new game gives you a random phobia. Fighting an enemy that matches it makes you %s:\n" % [h("Phobias."), bad("afraid")] + \
		_phobia_list() + "\n" + \
		"%s Every level: +9 Max HP, +5 Max Mind, more ATK/DEF/AGI, and new skills at Lv 2, 3, 4, 5, 6 and 8." % h("Leveling.")


func _phobia_list() -> String:
	var s := ""
	var what_id := {"dark": "makhluk kegelapan (stage 2)", "bloody": "musuh berdarah, dan pendarahanmu sendiri", "worm": "cacing dan parasit",
		"eye": "makhluk bermata banyak dan tumor", "beast": "anjing gila dan binatang buas"}
	var what_en := {"dark": "dark spirits (stage 2)", "bloody": "bloody enemies, and your own bleeding", "worm": "worms and parasites",
		"eye": "eye creatures and tumors", "beast": "dogs and beasts"}
	var what: Dictionary = what_id if Loc.lang == "id" else what_en
	for k in DB.PHOBIAS:
		s += "  \u2022 %s: %s\n" % [Loc.t(DB.PHOBIAS[k]["name"]), dim(what.get(DB.PHOBIAS[k]["tag"], ""))]
	return s


func _ch_items() -> String:
	if Loc.lang == "id":
		var s := "Item konsumsi dapat digunakan dari Tas (I) di papan atau dengan perintah Item saat bertarung.\n[table=2]"
		for id in DB.ITEMS:
			var it: Dictionary = DB.ITEMS[id]
			if it["kind"] != "consumable":
				continue
			var where: String = {"both": "papan & tarung", "battle": "hanya tarung", "board": "hanya papan"}[it.get("use", "both")]
			s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id), h(DB.item_name(id)), dim("%s \u2022 %d koin" % [where, int(it["price"])]), DB.item_desc(id)]
		s += "[/table]\n" + h("BAHAN RACIKAN") + dim("  (dipakai di tab Racik, atau dijual ke pedagang)") + "\n[table=2]"
		for id2 in DB.ITEMS:
			var m: Dictionary = DB.ITEMS[id2]
			if m["kind"] != "material":
				continue
			s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id2), h(DB.item_name(id2)), dim("%d koin" % int(m["price"])), DB.item_desc(id2)]
		s += "[/table]\n" + h("UANG & KOIN") + "\n%s %s %s %s  Koin diperoleh dari musuh, peti, peristiwa, dan pencuri (habisi sebelum kabur!)." % [
			img(G + "items/koin.png"), img(G + "items/uang.png"), img(G + "items/kantong.png"), img(G + "items/emas.png")]
		return s
	var s := "Consumables can be used from the Bag (I) on the board or with the Item command in battle. Some only work in one of them.\n[table=2]"
	for id in DB.ITEMS:
		var it: Dictionary = DB.ITEMS[id]
		if it["kind"] != "consumable":
			continue
		var where: String = {"both": "board & battle", "battle": "battle only", "board": "board only"}[it.get("use", "both")]
		s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id), h(DB.item_name(id)), dim("%s \u2022 %d coins" % [where, int(it["price"])]), DB.item_desc(id)]
	s += "[/table]\n" + h("MATERIALS") + dim("  (used for Crafting, or sold to merchants)") + "\n[table=2]"
	for id2 in DB.ITEMS:
		var m: Dictionary = DB.ITEMS[id2]
		if m["kind"] != "material":
			continue
		s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id2), h(DB.item_name(id2)), dim("%d coins" % int(m["price"])), DB.item_desc(id2)]
	s += "[/table]\n" + h("MONEY") + "\n%s %s %s %s  Coins drop from enemies, chests, events and thieves (kill them before they run!)." % [
		img(G + "items/koin.png"), img(G + "items/uang.png"), img(G + "items/kantong.png"), img(G + "items/emas.png")]
	return s


func _ch_gear() -> String:
	if Loc.lang == "id":
		var s := "Kamu memiliki tiga slot perlengkapan: %s, %s, dan %s. Pasang dari Tas; klik slot di kiri untuk melepas. " % [h("Senjata"), h("Zirah"), h("Aksesori")] + \
			"Senjata dua tangan memiliki damage besar namun melemah parah saat %s.\n" % bad("Lengan Patah")
		for kind in ["weapon", "armor", "accessory"]:
			s += "\n" + h(DB.kind_label(kind).to_upper()) + "\n[table=2]"
			for id in DB.ITEMS:
				var it: Dictionary = DB.ITEMS[id]
				if it["kind"] != kind:
					continue
				var stats := ""
				if kind == "weapon":
					stats = "ATK +%d \u2022 Akurasi %d%%%s" % [int(it.get("atk", 0)), int(it.get("acc", 90)), " \u2022 2 Tangan" if int(it.get("hands", 1)) == 2 else ""]
				elif it.has("def"):
					stats = "DEF +%d" % int(it["def"])
				s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id), h(DB.item_name(id)), dim("%s \u2022 %d koin" % [stats, int(it["price"])]), DB.item_desc(id)]
			s += "[/table]"
		return s
	var s := "You have three slots: %s, %s and %s. Equip from the Bag; click a slot on the left to unequip. " % [h("Weapon"), h("Armor"), h("Accessory")] + \
		"Two-handed weapons hit hard but suffer more from a %s.\n" % bad("Broken Arm")
	for kind in ["weapon", "armor", "accessory"]:
		s += "\n" + h(DB.kind_label(kind).to_upper() + "S") + "\n[table=2]"
		for id in DB.ITEMS:
			var it: Dictionary = DB.ITEMS[id]
			if it["kind"] != kind:
				continue
			var stats := ""
			if kind == "weapon":
				stats = "ATK +%d \u2022 Acc %d%%%s" % [int(it.get("atk", 0)), int(it.get("acc", 90)), " \u2022 2H" if int(it.get("hands", 1)) == 2 else ""]
			elif it.has("def"):
				stats = "DEF +%d" % int(it["def"])
			s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "items/%s.png" % id), h(DB.item_name(id)), dim("%s \u2022 %d coins" % [stats, int(it["price"])]), DB.item_desc(id)]
		s += "[/table]"
	return s


func _ch_crafting() -> String:
	var prefix := "Buka Tas (I) dan pilih tab %s. Gabungkan bahan-bahan yang kamu temukan di jalan:\n\n[table=2]" % h("Racik") if Loc.lang == "id" else "Open the Bag (I) and choose the %s tab. Combine materials you find on the road:\n\n[table=2]" % h("Craft")
	var s := prefix
	for r in DB.RECIPES:
		var parts := []
		for k in r["in"]:
			parts.append("%s %s x%d" % [img(G + "items/%s.png" % k), DB.item_name(k), int(r["in"][k])])
		s += "[cell]%s  [/cell][cell]%s\n%s\n[/cell]" % [img(G + "items/%s.png" % r["out"]), h(DB.item_name(r["out"])), dim("= " + "  +  ".join(parts))]
	return s + "[/table]"


func _ch_skills() -> String:
	if Loc.lang == "id":
		var s := "Skill membutuhkan %s. Terbuka otomatis saat mencapai level tertentu. %s memperkuat dayanya sebesar 40%%.\n\n[table=2]" % [h("Mind"), h("Tongkat Gaib")]
		for id in DB.SKILLS:
			var sk: Dictionary = DB.SKILLS[id]
			s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "icons/mind.png"), h(DB.skill_name(id)), dim("Lv %d \u2022 %d Mind" % [int(sk["lv"]), int(sk["mind"])]), DB.skill_desc(id)]
		return s + "[/table]"
	var s := "Skills cost %s. They unlock automatically when you reach the listed level. The %s boosts their power by 40%%.\n\n[table=2]" % [h("Mind"), h("Occult Staff")]
	for id in DB.SKILLS:
		var sk: Dictionary = DB.SKILLS[id]
		s += "[cell]%s  [/cell][cell]%s  %s\n%s\n[/cell]" % [img(G + "icons/mind.png"), h(DB.skill_name(id)), dim("Lv %d \u2022 %d Mind" % [int(sk["lv"]), int(sk["mind"])]), DB.skill_desc(id)]
	return s + "[/table]"


func _ch_bestiary() -> String:
	var s := ""
	var groups := [
		[1, ["preman", "copet", "begal", "perampok", "anjing", "jagoan", "boss_jagal"]],
		[2, ["imp", "pocong", "bayangan", "iblis", "tuyul", "hellhound", "boss_raja"]],
		[3, ["tumor", "mata", "cacing", "daging", "spora", "bedah", "boss_induk"]],
		[0, ["mimic"]],
	]
	var is_id := (Loc.lang == "id")
	for g in groups:
		var stg: int = g[0]
		var title: String = ""
		if stg > 0:
			title = ("STAGE %d \u2022 %s" % [stg, DB.stage_name(stg).to_upper()])
		else:
			title = "DI MANA SAJA" if is_id else "ANYWHERE"
		s += "\n" + h(title) + "\n[table=2]"
		for id in g[1]:
			var e: Dictionary = DB.ENEMIES[id]
			var tag := ""
			if e.get("boss", false):
				tag = bad(" BOSS")
			elif e.get("elite", false):
				tag = "[color=#ffa848] ELITE[/color]"
			var skills := []
			var effects := []
			for sk in e["skills"]:
				skills.append(Loc.t(sk["name"]))
				if sk.has("status") and not effects.has(DB.status_name(sk["status"])):
					effects.append(DB.status_name(sk["status"]))
				if sk["kind"] in ["steal_gold", "steal_item"]:
					var theft_str := "Pencurian" if is_id else "Theft"
					if not effects.has(theft_str):
						effects.append(theft_str)
			var parts := []
			for p in DB.PARTS[e["parts"]]:
				parts.append(DB.part_name(p))
			var sz := 64 if not e.get("big", false) else 96
			var moves_lbl := "Jurus:" if is_id else "Moves:"
			var eff_lbl := "Efek Buruk:" if is_id else "Inflicts:"
			var part_lbl := "Bagian:" if is_id else "Parts:"
			s += "[cell]%s  [/cell][cell]%s%s\n%s\n%s\n%s %s\n%s %s\n%s %s\n[/cell]" % [
				img(G + "enemies/%s.png" % id, sz), h(DB.enemy_name(id)), tag,
				dim("HP %d \u2022 ATK %d \u2022 DEF %d \u2022 AGI %d \u2022 EXP %d" % [int(e["hp"]), int(e["atk"]), int(e["def"]), int(e["agi"]), int(e["exp"])]),
				DB.enemy_desc(id), dim(moves_lbl), ", ".join(skills), dim(eff_lbl), bad(", ".join(effects)) if not effects.is_empty() else "-",
				dim(part_lbl), ", ".join(parts)]
		s += "[/table]"
	return s


func _ch_stages() -> String:
	var s := ""
	var is_id := (Loc.lang == "id")
	for k in [1, 2, 3]:
		var st: Dictionary = DB.STAGES[k]
		var rest_lbl := "Tempat istirahat:" if is_id else "Rest spot:"
		var shrine_lbl := "Altar:" if is_id else "Shrine:"
		var boss_lbl := "Boss:" if is_id else "Boss:"
		s += "%s\n%s %s\n%s\n%s %s, %s %s, %s %s\n\n" % [
			img(G + "bg/bg_s%d.png" % k), h("STAGE %d: %s" % [k, DB.stage_name(k)]), dim("(" + DB.stage_sub(k) + ")"), DB.stage_desc(k),
			dim(rest_lbl), Loc.t(st["rest_name"]), dim(shrine_lbl), Loc.t(st["shrine_name"]), dim(boss_lbl), DB.enemy_name(st["boss"])]
	if is_id:
		s += "%s Setelah mengalahkan boss terakhir kamu dapat memulai %s: musuh menjadi lebih kuat, harga naik, tetapi kamu mempertahankan level dan perlengkapanmu." % [h("Siklus Baru (New Game+)."), h("Siklus Baru")]
	else:
		s += "%s After the final boss you can start a %s: enemies get stronger, prices go up, but you keep your level and gear." % [h("New Cycle."), h("New Cycle")]
	return s


func _ch_tips() -> String:
	var tips: Array = []
	if Loc.lang == "id":
		tips = [
			"Selalu bawa %s. Pendarahan yang diabaikan akan berubah menjadi Infeksi." % h("Perban"),
			"Simpan %s untuk patah tulang: Kaki Patah mengurangi angka dadu DAN mencegahmu kabur dari pertarungan." % h("Bidai"),
			"Makan sebelum mencapai Lapar II (Kenyang di bawah 50). Bungkus Nasi adalah makanan paling mengenyangkan dan hemat.",
			"Gunakan %s saat musuh bersiap melancarkan serangan besar: serangan tertahan hanya menghasilkan sedikit luka." % h("Bertahan (Defend)"),
			"Incar %s pada musuh lemah, incar %s pada musuh berdaya serang tinggi, dan incar %s pada musuh yang lincah." % [h("Kepala"), h("Lengan"), h("Kaki")],
			"Tebas %s pada Pocong untuk membebaskan jiwanya secara damai dan mengakhiri pertarungan seketika (serta menenangkan Mind)." % h("Tali Kafan"),
			"Habisi pencuri (Copet, Tuyul) secepatnya. Jika mereka kabur, koin atau barangmu hilang selamanya.",
			"Gumpalan Tumor akan membelah diri saat terluka parah. Kalahkan mereka dengan satu serangan telak berkekuatan besar.",
			"%s membatalkan Kutukan; %s menyembuhkan hampir seluruh penyakit dengan imbalan koin atau darah." % [h("Garam Kasar dan Air Suci"), h("berdoa di Altar")],
			"Harta karun di jalan buntu sangat berharga. Bawa %s untuk membuka peti terkunci." % h("Kunci Tua"),
			"Jebakan tersembunyi dapat menyergap saat kamu melangkah lewat. %s dapat mendeteksinya." % h("Kacamata"),
			"Membuka menu jeda dan buku panduan ini tidak menghabiskan giliran. Pelajari jurus musuh di Bestiary sebelum menghadapi Boss.",
			"Kotak Misteri terkadang memberimu %s. Jawab dengan benar untuk meraih koin, EXP, dan Mind!" % h("teka-teki"),
		]
	else:
		tips = [
			"Always carry a %s. Bleeding turns into Infection if you ignore it." % h("Bandage"),
			"Keep a %s for broken bones: a Broken Leg slows your dice AND stops you from fleeing." % h("Splint"),
			"Eat before Hunger II. Rice Packs are the best value food.",
			"Use %s when you see a big hit coming: blocked hits barely hurt." % h("Defend"),
			"Go for the %s on weak enemies, the %s on dangerous hitters, and the %s on fast ones." % [h("Head"), h("Arms"), h("Legs")],
			"Cut a Pocong's %s to free its soul and end the fight instantly (and calm your mind)." % h("Shroud Knot"),
			"Kill thieves (Pickpocket, Tuyul) quickly. If they flee, your coins are gone for good.",
			"Tumor Blobs split when badly hurt. Finish them with one big hit.",
			"%s cancel Curses; %s cures nearly everything for a price." % [h("Coarse Salt and Holy Water"), h("praying at a Shrine")],
			"Treasure at dead ends is worth the detour. Bring an %s for locked chests." % h("Old Key"),
			"Hidden traps can snap shut as you walk past. %s reveal them." % h("Glasses"),
			"The pause menu and this book never cost a turn. Read the enemy's moves in the Bestiary before boss fights.",
			"Mystery tiles may ask you a %s. Answer correctly for coins, EXP and Mind!" % h("riddle"),
		]
	var s := ""
	for t in tips:
		s += "\u2022 %s\n\n" % t
	return s
