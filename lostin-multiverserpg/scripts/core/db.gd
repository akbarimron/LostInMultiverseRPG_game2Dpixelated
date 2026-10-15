extends Node
## Static content database: items, equipment, statuses, skills, enemies, stages, events.
## Autoload name: DB   (internal ids stay short; every player-facing text is English)

const GEN := "res://assets/gen/"

# -----------------------------------------------------------------------------
# STAGES
# -----------------------------------------------------------------------------
const STAGES := {
	1: {
		"name": "Grim City", "sub": "The Real World",
		"intro": "That night the city felt wrong. Street lamps flickered, and the alleys\ntwisted into a labyrinth that was never there before...",
		"grid": Vector2i(7, 5), "rim": Color("#e8c42a"),
		"enemies": ["preman", "copet", "begal", "perampok", "anjing"],
		"elite": ["jagoan"], "boss": "boss_jagal",
		"rest_name": "Night Watch Post", "shrine_name": "Old Prayer House", "music": "music_s1",
		"desc": "Your own city, gone wrong. Thugs, pickpockets and biker bandits rule the maze of alleys.",
	},
	2: {
		"name": "Dimension of Darkness", "sub": "Hell",
		"intro": "The gate swallows you. The air reeks of sulfur, cracked ground spits\nlava. Demonic whispers call your name...",
		"grid": Vector2i(8, 5), "rim": Color("#e04a10"),
		"enemies": ["imp", "pocong", "bayangan", "iblis", "tuyul"],
		"elite": ["hellhound"], "boss": "boss_raja",
		"rest_name": "Blue Bonfire", "shrine_name": "Blood Altar", "music": "music_s2",
		"desc": "A burning underworld of demons and restless spirits. Curses and fear are everywhere.",
	},
	3: {
		"name": "Tumor Dimension", "sub": "Womb of Flesh",
		"intro": "The walls around you pulse. Everything is alive, growing,\ndividing. This world is a body, and it is sick...",
		"grid": Vector2i(8, 6), "rim": Color("#d2c242"),
		"enemies": ["tumor", "mata", "cacing", "daging", "spora"],
		"elite": ["bedah"], "boss": "boss_induk",
		"rest_name": "Warm Pouch", "shrine_name": "Ancient Heart", "music": "music_s3",
		"desc": "A living world of flesh. Infections, parasites and tumors grow on anyone who stays too long.",
	},
}

const TILE_INFO := {
	"start":    {"name": "Start",      "color": Color("#7ec45c"), "desc": "Where you began this stage."},
	"empty":    {"name": "Road",       "color": Color("#3a3048"), "desc": "A quiet road. Too quiet."},
	"enemy":    {"name": "Minions",    "color": Color("#e85a42"), "desc": "Ordinary enemies block the way."},
	"elite":    {"name": "Elite",      "color": Color("#ffa848"), "desc": "A strong enemy. Big rewards."},
	"boss":     {"name": "Boss Gate",  "color": Color("#c64c98"), "desc": "The guardian of the dimension gate."},
	"treasure": {"name": "Treasure",   "color": Color("#ffe86a"), "desc": "A chest full of loot... or a trap."},
	"item":     {"name": "Loot",       "color": Color("#c6b68a"), "desc": "Something is lying around here."},
	"merchant": {"name": "Merchant",   "color": Color("#6c92ea"), "desc": "Buy and sell weapons, armor, medicine."},
	"trap":     {"name": "Trap",       "color": Color("#a03030"), "desc": "Watch your step."},
	"event":    {"name": "Mystery",    "color": Color("#9c5cd4"), "desc": "Something strange awaits."},
	"rest":     {"name": "Rest Spot",  "color": Color("#388a3c"), "desc": "Recover body and mind."},
	"shrine":   {"name": "Shrine",     "color": Color("#62c8b8"), "desc": "Pray, sacrifice, or gamble."},
	"warp":     {"name": "Portal",     "color": Color("#2a8a8a"), "desc": "Takes you to another portal."},
}

# -----------------------------------------------------------------------------
# ITEMS
# kind: consumable | material | weapon | armor | accessory
# use: "both" | "battle" | "board"
# -----------------------------------------------------------------------------
const ITEMS := {
	# ---------------- consumables
	"perban": {"name": "Bandage", "kind": "consumable", "use": "both", "price": 18,
		"desc": "Stops Bleeding. +12 HP.", "heal": 12, "cure": ["bleed"]},
	"obat_merah": {"name": "Antiseptic", "kind": "consumable", "use": "both", "price": 32,
		"desc": "Infection -2 stages. +6 HP.", "heal": 6, "cure_stage": {"infect": 2}},
	"bidai": {"name": "Splint", "kind": "consumable", "use": "both", "price": 42,
		"desc": "Sets broken bones (arm & leg).", "cure": ["frac_arm", "frac_leg"]},
	"penawar": {"name": "Antidote", "kind": "consumable", "use": "both", "price": 28,
		"desc": "Cures Poison and Toxic Poison.", "cure": ["poison", "toxic"]},
	"roti": {"name": "Bread", "kind": "consumable", "use": "both", "price": 10,
		"desc": "Hunger -30. +4 HP.", "food": 30, "heal": 4},
	"nasi": {"name": "Rice Pack", "kind": "consumable", "use": "both", "price": 18,
		"desc": "Hunger -55. +10 HP.", "food": 55, "heal": 10},
	"air": {"name": "Water Bottle", "kind": "consumable", "use": "both", "price": 8,
		"desc": "Puts out Burning. Mind +6, Hunger -5.", "mind": 6, "food": 5, "cure": ["burn"]},
	"kopi": {"name": "Black Coffee", "kind": "consumable", "use": "both", "price": 14,
		"desc": "Mind +28. Removes Stun.", "mind": 28, "cure": ["stun"]},
	"jamu": {"name": "Herbal Tonic", "kind": "consumable", "use": "both", "price": 30,
		"desc": "Cures Poison & Parasitic Worms. +10 HP, Mind -4.", "heal": 10, "mind": -4, "cure": ["poison", "parasite"]},
	"daging": {"name": "Mystery Meat", "kind": "consumable", "use": "both", "price": 4,
		"desc": "Hunger -45. Might be infected...", "food": 45, "risk": {"parasite": 0.3, "infect": 0.2}},
	"permen": {"name": "Candy", "kind": "consumable", "use": "both", "price": 6,
		"desc": "Sweet comfort. Mind +12, Hunger -4.", "mind": 12, "food": 4},
	"batu": {"name": "Rock", "kind": "consumable", "use": "battle", "price": 3, "target": "enemy",
		"desc": "Throw it! 12 dmg, 40% Stun.", "dmg": 12, "inflict": {"stun": 0.4}},
	"molotov": {"name": "Molotov", "kind": "consumable", "use": "battle", "price": 40, "target": "all",
		"desc": "Firebomb on all enemies. 18 dmg + Burning.", "dmg": 18, "inflict": {"burn": 0.85}},
	"garam": {"name": "Coarse Salt", "kind": "consumable", "use": "both", "price": 22, "target": "enemy",
		"desc": "Vs. dark spirits: 30 dmg + Fear. On the board: removes Curse.", "dmg": 30, "vs_tag": "dark", "inflict": {"fear": 0.7}, "cure": ["curse"]},
	"air_suci": {"name": "Holy Water", "kind": "consumable", "use": "both", "price": 50,
		"desc": "Removes Curse & Fear. Blessed for 15 steps.", "cure": ["curse", "fear", "insane"], "buff": {"blessed": 15}},
	"obat_cacing": {"name": "Dewormer", "kind": "consumable", "use": "both", "price": 24,
		"desc": "Kills Parasitic Worms.", "cure": ["parasite"]},
	"obat_mata": {"name": "Eye Drops", "kind": "consumable", "use": "both", "price": 24,
		"desc": "Cures Blindness and Hallucinations.", "cure": ["blind", "hallu"]},
	"jimat_kertas": {"name": "Paper Talisman", "kind": "consumable", "use": "both", "price": 34,
		"desc": "Banishes Fear & Madness. Mind +15.", "mind": 15, "cure": ["fear", "insane", "hallu"]},
	"dadu_emas": {"name": "Golden Die", "kind": "consumable", "use": "board", "price": 60,
		"desc": "Your next roll: YOU choose the number (1-6)."},
	"kunci": {"name": "Old Key", "kind": "consumable", "use": "board", "price": 28,
		"desc": "Opens a locked chest safely."},
	"pisau_operasi": {"name": "Scalpel Kit", "kind": "consumable", "use": "board", "price": 40,
		"desc": "Emergency surgery: removes Tumor Growth. HP -15, Bleeding.", "cure": ["tumor"]},
	"bom_asap": {"name": "Smoke Bomb", "kind": "consumable", "use": "battle", "price": 32, "target": "self",
		"desc": "Escape 100% (does not work on Bosses)."},

	# ---------------- materials (crafting / selling)
	"kain": {"name": "Rag", "kind": "material", "price": 6, "desc": "For bandages, splints and molotovs."},
	"kayu": {"name": "Wood", "kind": "material", "price": 5, "desc": "For splints and weapons."},
	"besi": {"name": "Scrap Iron", "kind": "material", "price": 10, "desc": "For weapons and tools. Can jam traps."},
	"tali": {"name": "Rope", "kind": "material", "price": 6, "desc": "Ties everything together."},
	"paku": {"name": "Nails", "kind": "material", "price": 5, "desc": "Makes weapons hurt more."},
	"botol": {"name": "Empty Bottle", "kind": "material", "price": 3, "desc": "Holds potions and molotovs."},
	"minyak": {"name": "Kerosene", "kind": "material", "price": 12, "desc": "Highly flammable."},
	"herbal": {"name": "Herb Leaves", "kind": "material", "price": 8, "desc": "Base for traditional medicine."},
	"tanduk": {"name": "Demon Horn", "kind": "material", "price": 30, "desc": "Hard and still warm."},
	"batu_jiwa": {"name": "Soul Stone", "kind": "material", "price": 45, "desc": "It beats like a heart."},
	"daging_tumor": {"name": "Tumor Flesh", "kind": "material", "price": 20, "desc": "Still twitching. Disgusting."},
	"taring": {"name": "Fang", "kind": "material", "price": 15, "desc": "A sharp fang from a beast."},

	# ---------------- weapons  (atk, acc, dtype, procs, crit, hands)
	"w_tangan": {"name": "Bare Fists", "kind": "weapon", "price": 0, "atk": 2, "acc": 95, "dtype": "blunt",
		"proc": {"stun": 0.05}, "desc": "Just your fists."},
	"w_penggaris": {"name": "Steel Ruler", "kind": "weapon", "price": 15, "atk": 5, "acc": 96, "dtype": "blade",
		"proc": {"bleed": 0.15}, "desc": "Every student's secret weapon. 15% Bleeding."},
	"w_sapu": {"name": "Broomstick", "kind": "weapon", "price": 25, "atk": 7, "acc": 90, "dtype": "blunt", "hands": 2,
		"proc": {"stun": 0.12}, "desc": "Two-handed. 12% Stun."},
	"w_pipa": {"name": "Lead Pipe", "kind": "weapon", "price": 60, "atk": 9, "acc": 86, "dtype": "blunt",
		"proc": {"break": 0.22, "stun": 0.1}, "desc": "22% Bone Break, 10% Stun."},
	"w_golok": {"name": "Machete", "kind": "weapon", "price": 110, "atk": 11, "acc": 88, "dtype": "blade",
		"proc": {"bleed": 0.35}, "desc": "35% Bleeding."},
	"w_celurit": {"name": "Sickle", "kind": "weapon", "price": 100, "atk": 10, "acc": 93, "dtype": "blade", "crit": 12,
		"proc": {"bleed": 0.3}, "desc": "Crit +12%. 30% Bleeding."},
	"w_bat": {"name": "Nail Bat", "kind": "weapon", "price": 120, "atk": 13, "acc": 82, "dtype": "blunt", "hands": 2,
		"proc": {"bleed": 0.2, "break": 0.15}, "desc": "Two-handed. Bleeding & Bone Break."},
	"w_linggis": {"name": "Crowbar", "kind": "weapon", "price": 140, "atk": 14, "acc": 80, "dtype": "blunt", "hands": 2,
		"proc": {"break": 0.32}, "desc": "Two-handed. 32% Bone Break."},
	"w_pedang_tulang": {"name": "Bone Sword", "kind": "weapon", "price": 220, "atk": 17, "acc": 88, "dtype": "blade",
		"proc": {"bleed": 0.3}, "desc": "Forged from demon bone."},
	"w_trisula": {"name": "Hell Trident", "kind": "weapon", "price": 280, "atk": 19, "acc": 85, "dtype": "pierce", "hands": 2, "crit": 8,
		"proc": {"burn": 0.3}, "desc": "Two-handed. 30% Burning."},
	"w_kapak": {"name": "Executioner Axe", "kind": "weapon", "price": 300, "atk": 22, "acc": 76, "dtype": "blade", "hands": 2,
		"proc": {"bleed": 0.4, "break": 0.2}, "desc": "Two-handed. Brutal."},
	"w_scalpel": {"name": "Surgeon's Scalpel", "kind": "weapon", "price": 300, "atk": 16, "acc": 99, "dtype": "blade", "crit": 22,
		"proc": {"bleed": 0.5}, "desc": "Precise. Crit +22%, 50% Bleeding."},
	"w_gergaji": {"name": "Flesh Saw", "kind": "weapon", "price": 420, "atk": 26, "acc": 80, "dtype": "blade", "hands": 2,
		"proc": {"bleed": 0.6}, "desc": "Two-handed. 60% Bleeding."},
	"w_tongkat": {"name": "Occult Staff", "kind": "weapon", "price": 200, "atk": 8, "acc": 90, "dtype": "occult",
		"skill_boost": 0.4, "mind_regen": 3, "desc": "Skills +40% power. Mind +3 per turn."},

	# ---------------- armor
	"a_seragam": {"name": "School Uniform", "kind": "armor", "price": 10, "def": 1, "desc": "White and grey. Full of memories."},
	"a_jaket": {"name": "Leather Jacket", "kind": "armor", "price": 70, "def": 4, "resist": {"bleed": 0.3}, "desc": "DEF 4. Resists Bleeding 30%."},
	"a_rompi": {"name": "Police Vest", "kind": "armor", "price": 150, "def": 7, "resist": {"bleed": 0.2}, "desc": "DEF 7. Stab-proof vest."},
	"a_zirah_tulang": {"name": "Bone Armor", "kind": "armor", "price": 260, "def": 10, "resist": {"fear": 0.5}, "desc": "DEF 10. Resists Fear 50%."},
	"a_jubah": {"name": "Demon Robe", "kind": "armor", "price": 240, "def": 6, "mind_bonus": 20, "resist": {"curse": 1.0}, "desc": "DEF 6. Mind +20. Immune to Curse."},
	"a_hazmat": {"name": "Hazmat Suit", "kind": "armor", "price": 320, "def": 8, "resist": {"infect": 0.7, "poison": 0.7, "toxic": 0.7, "parasite": 0.7, "tumor": 0.5}, "desc": "DEF 8. Resists infection, poison, parasites."},

	# ---------------- accessories
	"a_helm": {"name": "Steel Helmet", "kind": "accessory", "price": 90, "def": 3, "resist": {"stun": 1.0}, "desc": "DEF +3. Immune to Stun."},
	"x_kalung": {"name": "Charm Necklace", "kind": "accessory", "price": 120, "mind_bonus": 10, "resist": {"fear": 1.0, "insane": 0.5}, "desc": "Immune to Fear. Mind +10."},
	"x_jam": {"name": "Wristwatch", "kind": "accessory", "price": 80, "agi": 3, "desc": "AGI +3. Always on time."},
	"x_kacamata": {"name": "Glasses", "kind": "accessory", "price": 70, "acc": 10, "resist": {"blind": 1.0, "hallu": 0.5}, "desc": "Accuracy +10. Immune to Blind. Reveals hidden traps."},
	"x_masker": {"name": "Face Mask", "kind": "accessory", "price": 60, "resist": {"infect": 0.5, "poison": 0.5, "toxic": 0.4}, "desc": "Resists Infection & Poison 50%."},
	"x_cincin": {"name": "Blood Ring", "kind": "accessory", "price": 200, "lifesteal": 0.15, "desc": "Absorb 15% of damage dealt as HP."},
	"x_sepatu": {"name": "Running Shoes", "kind": "accessory", "price": 110, "agi": 2, "dice": 1, "desc": "Dice +1. AGI +2."},
}

const RECIPES := [
	{"out": "perban", "n": 1, "in": {"kain": 2}},
	{"out": "bidai", "n": 1, "in": {"kayu": 1, "kain": 1, "tali": 1}},
	{"out": "molotov", "n": 1, "in": {"botol": 1, "minyak": 1, "kain": 1}},
	{"out": "obat_merah", "n": 1, "in": {"herbal": 2, "botol": 1}},
	{"out": "jamu", "n": 1, "in": {"herbal": 1, "air": 1}},
	{"out": "obat_cacing", "n": 1, "in": {"herbal": 2, "daging_tumor": 1}},
	{"out": "w_bat", "n": 1, "in": {"kayu": 2, "paku": 2}},
	{"out": "pisau_operasi", "n": 1, "in": {"besi": 1, "kain": 1}},
	{"out": "jimat_kertas", "n": 1, "in": {"kain": 1, "batu_jiwa": 1}},
	{"out": "air_suci", "n": 1, "in": {"air": 1, "batu_jiwa": 1}},
	{"out": "a_zirah_tulang", "n": 1, "in": {"tanduk": 2, "taring": 2, "tali": 1}},
	{"out": "w_pedang_tulang", "n": 1, "in": {"tanduk": 1, "taring": 2, "besi": 1}},
]

# -----------------------------------------------------------------------------
# STATUS EFFECTS  (inspired by Fear & Hunger)
# cause / cure are shown in the Guide Book
# -----------------------------------------------------------------------------
const STATUS := {
	"bleed":    {"name": "Bleeding", "bad": true, "max": 3, "desc": "Lose HP every turn and every step. Untreated wounds can become Infected.",
		"cause": "Blades, claws, bites, spiked traps.", "cure": "Bandage, First Aid skill, resting."},
	"infect":   {"name": "Infected Wound", "bad": true, "max": 3, "desc": "Max HP -10% per stage. Stage III drains HP and Mind every step.",
		"cause": "Untreated bleeding, rabid bites, pus, rusty junk.", "cure": "Antiseptic (-2 stages), resting (-1)."},
	"frac_arm": {"name": "Broken Arm", "bad": true, "max": 1, "desc": "ATK -40%. Two-handed weapons lose even more power.",
		"cause": "Heavy blunt hits, failed lock-picking, pits.", "cure": "Splint."},
	"frac_leg": {"name": "Broken Leg", "bad": true, "max": 1, "desc": "Dice -2. You cannot dodge or flee.",
		"cause": "Bear traps, sweeping kicks, falls.", "cure": "Splint."},
	"stun":     {"name": "Stunned", "bad": true, "max": 1, "desc": "You lose your next turn.",
		"cause": "Heavy impacts, sedatives.", "cure": "Black Coffee, Steel Helmet (immune)."},
	"poison":   {"name": "Poisoned", "bad": true, "max": 1, "desc": "Lose HP each turn, getting worse over time. Wears off after a while on the board.",
		"cause": "Gas traps, rotten breath, spores.", "cure": "Antidote, Herbal Tonic."},
	"toxic":    {"name": "Toxic Poison", "bad": true, "max": 1, "desc": "Twice as deadly as normal poison.",
		"cause": "Spore clouds, acid, dirty needles.", "cure": "Antidote."},
	"parasite": {"name": "Parasitic Worms", "bad": true, "max": 1, "desc": "Hunger rises twice as fast and something drains your HP from inside.",
		"cause": "Worm bites, mystery meat.", "cure": "Dewormer, Herbal Tonic."},
	"blind":    {"name": "Blind", "bad": true, "max": 1, "desc": "Accuracy -40%. On the board you only see the tiles right next to you and your map turns blurry.",
		"cause": "Shadows swallowing light, flashing eyes, cursed wells.", "cure": "Eye Drops, Glasses (immune)."},
	"trauma":   {"name": "Severe Trauma", "bad": true, "max": 1, "desc": "Healing HURTS you instead. Ends when the battle ends.",
		"cause": "Brutal boss attacks.", "cure": "Win or escape the battle."},
	"burn":     {"name": "Burning", "bad": true, "max": 1, "desc": "Lose 5 HP every turn for 3 turns.",
		"cause": "Fire claws, lava, hell flames.", "cure": "Water Bottle, ends after battle."},
	"def_down": {"name": "Weakened Guard", "bad": true, "max": 1, "desc": "DEF -50% for 3 turns.",
		"cause": "Horn charges.", "cure": "Wait it out."},
	"silence":  {"name": "Silenced", "bad": true, "max": 1, "desc": "You cannot use Skills for 3 turns.",
		"cause": "A shadow's cold touch.", "cure": "Wait it out."},
	"fear":     {"name": "Fear", "bad": true, "max": 3, "desc": "Per level: your damage -12%, damage taken +12%, and you may freeze in place.",
		"cause": "Your phobia, scary enemies, horrifying events.", "cure": "Deep Breath skill, resting, Paper Talisman, Holy Water."},
	"insane":   {"name": "Madness", "bad": true, "max": 1, "desc": "Your Mind broke. You hallucinate, and your attacks may hit the wrong target... even you.",
		"cause": "Mind reaches 0.", "cure": "Raise Mind to 20+ (Coffee, Candy, Talisman)."},
	"hunger":   {"name": "Hunger", "bad": true, "max": 5, "desc": "Stages I-V: lower Max HP and ATK; stage IV slows your dice; stage V starves you.",
		"cause": "Walking. Every step makes you hungrier.", "cure": "Eat: Bread, Rice Pack, Mystery Meat."},
	"curse":    {"name": "Curse", "bad": true, "max": 1, "desc": "Your dice often roll 1 and money slips out of your pockets.",
		"cause": "Demons, stealing from spirits.", "cure": "Coarse Salt, Holy Water, praying at a Shrine."},
	"tumor":    {"name": "Tumor Growth", "bad": true, "max": 5, "desc": "Grows as you walk and lowers Max Mind. At stage V it eats your HP.",
		"cause": "Tumor creatures, touching living walls.", "cure": "Scalpel Kit (painful)."},
	"hallu":    {"name": "Hallucinating", "bad": true, "max": 1, "desc": "Accuracy -20%. Numbers and faces can't be trusted.",
		"cause": "Staring eyes.", "cure": "Eye Drops, Paper Talisman, wait 3 turns."},
	"defend":   {"name": "Guarding", "bad": false, "max": 1, "desc": "Damage taken -50% and a much wider parry zone.",
		"cause": "Choose Defend in battle.", "cure": "Lasts one round."},
	"bloodlust": {"name": "Bloodlust", "bad": false, "max": 1, "desc": "ATK +50% until you get hit.",
		"cause": "Casting Occult Fire.", "cure": "Ends when you take damage."},
	"focus":    {"name": "Focused", "bad": false, "max": 1, "desc": "Critical chance +30%, slightly wider perfect-parry zone.",
		"cause": "Deep Breath skill.", "cure": "Lasts 2 turns."},
	"regen":    {"name": "Regeneration", "bad": false, "max": 1, "desc": "Slowly recover HP.",
		"cause": "Some events and shrines.", "cure": "Timed."},
	"blessed":  {"name": "Blessed", "bad": false, "max": 1, "desc": "Immune to Fear, Curse and Madness.",
		"cause": "Holy Water, shrines, kind deeds.", "cure": "Lasts a number of steps."},
	"adren":    {"name": "Adrenaline", "bad": false, "max": 1, "desc": "ATK +25% and broken bones don't slow you down.",
		"cause": "Battle Cry skill.", "cure": "Lasts 3 turns."},
	"haste":    {"name": "Swift", "bad": false, "max": 1, "desc": "Dice +2 / AGI +5.",
		"cause": "Rare events.", "cure": "Timed."},
}

# statuses that vanish when a battle ends
const BATTLE_ONLY := ["stun", "trauma", "burn", "def_down", "silence", "defend", "bloodlust", "focus", "adren", "hallu"]

const PHOBIAS := {
	"gelap":  {"name": "Nyctophobia (fear of the dark)", "tag": "dark"},
	"darah":  {"name": "Hemophobia (fear of blood)", "tag": "bloody"},
	"cacing": {"name": "Helminthophobia (fear of worms)", "tag": "worm"},
	"mata":   {"name": "Ommatophobia (fear of eyes)", "tag": "eye"},
	"anjing": {"name": "Cynophobia (fear of dogs)", "tag": "beast"},
}

# -----------------------------------------------------------------------------
# PLAYER SKILLS
# -----------------------------------------------------------------------------
const SKILLS := {
	"beruntun": {"name": "Flurry", "lv": 1, "mind": 12, "target": "enemy",
		"desc": "3 quick hits (60% dmg) on random body parts."},
	"napas": {"name": "Deep Breath", "lv": 1, "mind": 0, "target": "self",
		"desc": "Mind +20, Fear -1, become Focused."},
	"pasir": {"name": "Sand Toss", "lv": 2, "mind": 8, "target": "enemy",
		"desc": "Blinds an enemy for 2 turns (it often misses)."},
	"p3k": {"name": "First Aid", "lv": 3, "mind": 15, "target": "self",
		"desc": "Stop Bleeding, +22 HP."},
	"teriak": {"name": "Battle Cry", "lv": 4, "mind": 18, "target": "all",
		"desc": "All enemies become afraid. You gain Adrenaline."},
	"api": {"name": "Occult Fire", "lv": 5, "mind": 26, "target": "all",
		"desc": "Fire on all enemies + Burning. Costs 6 HP. Grants Bloodlust."},
	"analisis": {"name": "Analyze Weakness", "lv": 6, "mind": 6, "target": "enemy",
		"desc": "Mark an enemy: your next hit on it is a guaranteed Critical."},
	"fatal": {"name": "Fatal Strike", "lv": 8, "mind": 30, "target": "enemy",
		"desc": "250% damage aimed at the head, +30% accuracy."},
}

# -----------------------------------------------------------------------------
# ENEMIES
# parts: head/body/arms/legs + special
# skill kinds: hit, multi, status, steal_gold, steal_item, summon, mind, heal, aoe_status
# -----------------------------------------------------------------------------
const PARTS := {
	"human": [
		{"id": "kepala", "name": "Head", "hp": 0.35, "hit": -25, "to_main": 0.5, "brk": "kill"},
		{"id": "badan", "name": "Body", "hp": 1.0, "hit": 0, "to_main": 1.0, "brk": "main"},
		{"id": "lengan", "name": "Arms", "hp": 0.3, "hit": -10, "to_main": 0.35, "brk": "arm"},
		{"id": "kaki", "name": "Legs", "hp": 0.3, "hit": -12, "to_main": 0.35, "brk": "leg"},
	],
	"beast": [
		{"id": "kepala", "name": "Head", "hp": 0.35, "hit": -25, "to_main": 0.5, "brk": "kill"},
		{"id": "badan", "name": "Body", "hp": 1.0, "hit": 0, "to_main": 1.0, "brk": "main"},
		{"id": "kaki", "name": "Legs", "hp": 0.3, "hit": -8, "to_main": 0.35, "brk": "leg"},
	],
	"pocong": [
		{"id": "kepala", "name": "Face", "hp": 0.4, "hit": -20, "to_main": 0.5, "brk": "kill"},
		{"id": "badan", "name": "Shroud", "hp": 1.0, "hit": 0, "to_main": 1.0, "brk": "main"},
		{"id": "tali", "name": "Shroud Knot", "hp": 0.25, "hit": -35, "to_main": 0.2, "brk": "free"},
	],
	"ghost": [
		{"id": "badan", "name": "Form", "hp": 1.0, "hit": -5, "to_main": 1.0, "brk": "main"},
		{"id": "inti", "name": "Dark Core", "hp": 0.3, "hit": -30, "to_main": 0.6, "brk": "kill"},
	],
	"blob": [
		{"id": "badan", "name": "Flesh Mass", "hp": 1.0, "hit": 5, "to_main": 1.0, "brk": "main"},
		{"id": "mata", "name": "Eye", "hp": 0.25, "hit": -20, "to_main": 0.4, "brk": "blind"},
		{"id": "inti", "name": "Tumor Core", "hp": 0.35, "hit": -28, "to_main": 0.6, "brk": "kill"},
	],
	"eyes": [
		{"id": "badan", "name": "Flesh Stalk", "hp": 1.0, "hit": 0, "to_main": 1.0, "brk": "main"},
		{"id": "mata", "name": "Main Eye", "hp": 0.4, "hit": -15, "to_main": 0.6, "brk": "kill"},
	],
	"worm": [
		{"id": "kepala", "name": "Mouth", "hp": 0.35, "hit": -18, "to_main": 0.5, "brk": "kill"},
		{"id": "badan", "name": "Segments", "hp": 1.0, "hit": 5, "to_main": 1.0, "brk": "main"},
	],
	"boss": [
		{"id": "kepala", "name": "Head", "hp": 0.3, "hit": -30, "to_main": 0.6, "brk": "stun"},
		{"id": "badan", "name": "Body", "hp": 1.0, "hit": 0, "to_main": 1.0, "brk": "main"},
		{"id": "lengan", "name": "Arm", "hp": 0.22, "hit": -12, "to_main": 0.35, "brk": "arm"},
	],
}

const PART_EFFECT := {
	"kill": "Destroyed = instant kill",
	"arm": "Broken = enemy hits weaker, can't steal",
	"leg": "Broken = enemy can't dodge or flee",
	"blind": "Destroyed = enemy goes blind",
	"free": "Cut = its soul is freed!",
	"stun": "Destroyed = boss is stunned",
	"main": "Main target, easiest to hit",
}

const ENEMIES := {
	# ============ STAGE 1 ============
	"preman": {"name": "Market Thug", "hp": 34, "atk": 7, "def": 1, "agi": 4, "exp": 9, "gold": [6, 14], "parts": "human",
		"tags": ["human"], "loot": [["roti", 0.3], ["kain", 0.35], ["w_pipa", 0.06]],
		"desc": "Runs the market with his fists. Loves breaking arms.",
		"skills": [
			{"name": "Haymaker", "kind": "hit", "power": 1.0, "w": 5, "msg": "throws a haymaker!"},
			{"name": "Bone Kick", "kind": "hit", "power": 1.1, "w": 2, "status": "frac_arm", "chance": 0.22, "msg": "kicks your arm hard!"},
			{"name": "Intimidate", "kind": "status", "w": 1, "status": "fear", "chance": 0.5, "msg": "barks: \"Wanna die, kid?!\""},
		]},
	"copet": {"name": "Pickpocket", "hp": 22, "atk": 5, "def": 0, "agi": 9, "exp": 8, "gold": [4, 10], "parts": "human",
		"tags": ["human"], "loot": [["koin_bonus", 0.5], ["permen", 0.3], ["x_jam", 0.05]], "flee_hp": 0.4,
		"desc": "Fast hands, faster feet. Steals your coins and runs when hurt.",
		"skills": [
			{"name": "Wallet Snatch", "kind": "steal_gold", "power": 0.0, "w": 4, "msg": "reaches into your pocket!"},
			{"name": "Razor", "kind": "hit", "power": 0.9, "w": 3, "status": "bleed", "chance": 0.45, "msg": "slashes with a razor blade!"},
		]},
	"begal": {"name": "Biker Bandit", "hp": 40, "atk": 9, "def": 2, "agi": 6, "exp": 13, "gold": [10, 20], "parts": "human",
		"tags": ["human", "bloody"], "loot": [["w_golok", 0.08], ["minyak", 0.3], ["perban", 0.25]],
		"desc": "A helmeted motorcycle robber with a bloody machete.",
		"skills": [
			{"name": "Machete Chop", "kind": "hit", "power": 1.15, "w": 4, "status": "bleed", "chance": 0.5, "msg": "swings the machete!"},
			{"name": "Hit and Run", "kind": "hit", "power": 1.3, "w": 2, "status": "stun", "chance": 0.3, "msg": "rams you with the motorbike!"},
			{"name": "Threaten", "kind": "status", "w": 1, "status": "fear", "chance": 0.45, "msg": "raises a blood-soaked machete."},
		]},
	"perampok": {"name": "Masked Robber", "hp": 36, "atk": 8, "def": 2, "agi": 5, "exp": 12, "gold": [12, 24], "parts": "human",
		"tags": ["human"], "loot": [["w_linggis", 0.06], ["kunci", 0.2], ["tali", 0.3]],
		"desc": "Balaclava, crowbar and a sack for your belongings.",
		"skills": [
			{"name": "Crowbar Smash", "kind": "hit", "power": 1.15, "w": 4, "status": "frac_arm", "chance": 0.2, "msg": "smashes with a crowbar!"},
			{"name": "Rob", "kind": "steal_item", "w": 2, "msg": "rips an item out of your bag!"},
			{"name": "Leg Sweep", "kind": "hit", "power": 0.8, "w": 1, "status": "frac_leg", "chance": 0.25, "msg": "sweeps your legs!"},
		]},
	"anjing": {"name": "Rabid Dog", "hp": 24, "atk": 7, "def": 0, "agi": 8, "exp": 8, "gold": [0, 4], "parts": "beast",
		"tags": ["beast", "bloody"], "loot": [["taring", 0.35], ["daging", 0.4]],
		"desc": "Foaming at the mouth. One bite can infect you.",
		"skills": [
			{"name": "Rabid Bite", "kind": "hit", "power": 1.0, "w": 4, "status": "infect", "chance": 0.3, "msg": "bites with a foaming mouth!"},
			{"name": "Maul", "kind": "multi", "power": 0.55, "hits": 2, "w": 2, "status": "bleed", "chance": 0.3, "msg": "tears at you!"},
		]},
	"jagoan": {"name": "Village Bruiser", "hp": 85, "atk": 11, "def": 4, "agi": 5, "exp": 40, "gold": [35, 60], "parts": "human",
		"tags": ["human"], "elite": true, "loot": [["w_sapu", 0.3], ["a_jaket", 0.35], ["nasi", 0.6], ["bidai", 0.4]],
		"desc": "A martial-arts tough guy with a bamboo spear. Heals with 'inner power'.",
		"skills": [
			{"name": "Bamboo Strike", "kind": "hit", "power": 1.1, "w": 4, "status": "frac_arm", "chance": 0.25, "msg": "strikes with a bamboo spear!"},
			{"name": "Tiger Style", "kind": "multi", "power": 0.6, "hits": 3, "w": 2, "msg": "unleashes Tiger Style silat!"},
			{"name": "Inner Power", "kind": "heal", "power": 0.2, "w": 1, "msg": "focuses his inner power."},
		]},
	"boss_jagal": {"name": "THE BUTCHER", "hp": 200, "atk": 13, "def": 4, "agi": 4, "exp": 110, "gold": [120, 160], "parts": "boss",
		"tags": ["human", "bloody"], "boss": true, "big": true, "loot": [["w_kapak", 1.0], ["nasi", 1.0], ["batu_jiwa", 1.0]],
		"desc": "Boss of Grim City. A giant cleaver, gold teeth and a gang on speed-dial.",
		"skills": [
			{"name": "Cleaver Chop", "kind": "hit", "power": 1.2, "w": 4, "status": "bleed", "chance": 0.55, "msg": "swings a giant meat cleaver!"},
			{"name": "Bone Crusher", "kind": "hit", "power": 1.5, "w": 2, "status": "frac_leg", "chance": 0.35, "msg": "slams the ground. Your bones shake!"},
			{"name": "Call the Gang", "kind": "summon", "summon": "preman", "w": 1, "msg": "whistles: \"OI! GET OVER HERE!\""},
			{"name": "Butcher's Rage", "kind": "multi", "power": 0.55, "hits": 3, "w": 1, "status": "trauma", "chance": 0.3, "msg": "goes on a blind rampage!"},
		]},

	# ============ STAGE 2 ============
	"imp": {"name": "Imp", "hp": 46, "atk": 12, "def": 2, "agi": 9, "exp": 20, "gold": [12, 22], "parts": "human",
		"tags": ["dark"], "loot": [["tanduk", 0.25], ["air", 0.3]],
		"desc": "A giggling little devil with burning claws.",
		"skills": [
			{"name": "Fire Claw", "kind": "hit", "power": 1.0, "w": 4, "status": "burn", "chance": 0.45, "msg": "scratches with blazing claws!"},
			{"name": "Devil Laugh", "kind": "mind", "power": 12, "w": 2, "msg": "shrieks with laughter right in your ear..."},
		]},
	"pocong": {"name": "Pocong", "hp": 58, "atk": 12, "def": 3, "agi": 3, "exp": 22, "gold": [10, 18], "parts": "pocong",
		"tags": ["dark"], "loot": [["kain", 0.6], ["batu_jiwa", 0.12]],
		"desc": "An Indonesian ghost trapped in its burial shroud. Cut the knot on its head to set it free.",
		"skills": [
			{"name": "Shroud Leap", "kind": "hit", "power": 1.15, "w": 3, "status": "stun", "chance": 0.25, "msg": "hops and crashes into you!"},
			{"name": "Empty Stare", "kind": "status", "w": 2, "status": "fear", "chance": 0.65, "msg": "stares at you with empty eyes..."},
			{"name": "Grave Stench", "kind": "status", "w": 1, "status": "poison", "chance": 0.5, "msg": "breathes a rotten stench!"},
		]},
	"bayangan": {"name": "Hungry Shade", "hp": 42, "atk": 11, "def": 5, "agi": 8, "exp": 21, "gold": [8, 16], "parts": "ghost",
		"tags": ["dark"], "loot": [["batu_jiwa", 0.15], ["kopi", 0.3]],
		"desc": "A living shadow that feeds on light, voices and sanity.",
		"skills": [
			{"name": "Whispers", "kind": "mind", "power": 16, "w": 3, "msg": "whispers about the things you regret..."},
			{"name": "Cold Touch", "kind": "hit", "power": 0.9, "w": 3, "status": "silence", "chance": 0.4, "msg": "touches you. Your voice is gone!"},
			{"name": "Swallow Light", "kind": "status", "w": 1, "status": "blind", "chance": 0.45, "msg": "swallows all the light!"},
		]},
	"iblis": {"name": "Horned Demon", "hp": 64, "atk": 14, "def": 4, "agi": 5, "exp": 28, "gold": [18, 30], "parts": "human",
		"tags": ["dark", "bloody"], "loot": [["tanduk", 0.5], ["w_trisula", 0.05], ["taring", 0.3]],
		"desc": "A red demon with a trident. Its curses ruin your luck.",
		"skills": [
			{"name": "Trident Thrust", "kind": "hit", "power": 1.1, "w": 4, "status": "bleed", "chance": 0.4, "msg": "stabs with its trident!"},
			{"name": "Hell Curse", "kind": "status", "w": 2, "status": "curse", "chance": 0.5, "msg": "chants an ancient curse!"},
			{"name": "Horn Charge", "kind": "hit", "power": 1.35, "w": 1, "status": "def_down", "chance": 0.5, "msg": "charges with its horns!"},
		]},
	"tuyul": {"name": "Tuyul", "hp": 30, "atk": 9, "def": 1, "agi": 12, "exp": 18, "gold": [20, 40], "parts": "human",
		"tags": ["dark"], "loot": [["koin_bonus", 0.8], ["permen", 0.4]], "flee_hp": 0.5,
		"desc": "A bald goblin-child spirit from Javanese folklore. It steals money.",
		"skills": [
			{"name": "Steal Money", "kind": "steal_gold", "w": 5, "msg": "sneaks in and steals your money! Hihihi!"},
			{"name": "Little Bite", "kind": "hit", "power": 0.8, "w": 2, "msg": "bites your ankle!"},
		]},
	"hellhound": {"name": "Hellhound", "hp": 120, "atk": 16, "def": 5, "agi": 9, "exp": 70, "gold": [50, 80], "parts": "beast",
		"tags": ["dark", "beast"], "elite": true, "loot": [["taring", 1.0], ["a_jubah", 0.3], ["w_pedang_tulang", 0.3], ["air_suci", 0.5]],
		"desc": "A three-eyed hound with a mane of fire. Its howl breaks the will.",
		"skills": [
			{"name": "Lava Bite", "kind": "hit", "power": 1.1, "w": 4, "status": "burn", "chance": 0.5, "msg": "bites with burning jaws!"},
			{"name": "Howl", "kind": "aoe_status", "w": 1, "status": "fear", "chance": 0.7, "msg": "howls loud enough to burst eardrums!"},
			{"name": "Pounce", "kind": "multi", "power": 0.6, "hits": 2, "w": 2, "status": "bleed", "chance": 0.35, "msg": "pounces savagely!"},
		]},
	"boss_raja": {"name": "KING OF DARKNESS", "hp": 320, "atk": 17, "def": 6, "agi": 6, "exp": 220, "gold": [220, 300], "parts": "boss",
		"tags": ["dark"], "boss": true, "big": true, "loot": [["a_zirah_tulang", 1.0], ["air_suci", 1.0], ["batu_jiwa", 1.0]],
		"desc": "Ruler of the Dimension of Darkness, crowned with horns and fire.",
		"skills": [
			{"name": "Hellfire", "kind": "hit", "power": 1.25, "w": 3, "status": "burn", "chance": 0.6, "msg": "vomits hellfire!"},
			{"name": "Eternal Terror", "kind": "status", "w": 2, "status": "fear", "chance": 0.8, "msg": "shows its true form..."},
			{"name": "King's Curse", "kind": "status", "w": 1, "status": "curse", "chance": 0.7, "msg": "brands you with a curse!"},
			{"name": "Summon Imps", "kind": "summon", "summon": "imp", "w": 1, "msg": "tears open a rift to hell!"},
			{"name": "Soul Drain", "kind": "mind", "power": 22, "w": 1, "msg": "sucks at your soul!"},
		]},

	# ============ STAGE 3 ============
	"tumor": {"name": "Tumor Blob", "hp": 70, "atk": 14, "def": 3, "agi": 2, "exp": 30, "gold": [14, 24], "parts": "blob",
		"tags": ["flesh", "eye"], "loot": [["daging_tumor", 0.6], ["herbal", 0.3]], "split": "tumor",
		"desc": "A mass of growing cells. When badly hurt, it SPLITS in two.",
		"skills": [
			{"name": "Pus Spray", "kind": "hit", "power": 1.0, "w": 4, "status": "infect", "chance": 0.45, "msg": "sprays yellow pus!"},
			{"name": "Cling", "kind": "status", "w": 1, "status": "tumor", "chance": 0.6, "msg": "presses tumor cells into your skin!"},
		]},
	"mata": {"name": "Eye Cluster", "hp": 56, "atk": 13, "def": 2, "agi": 6, "exp": 30, "gold": [12, 22], "parts": "eyes",
		"tags": ["flesh", "eye"], "loot": [["obat_mata", 0.3], ["daging_tumor", 0.3]],
		"desc": "Dozens of eyes on a flesh stalk. Its gaze breaks minds.",
		"skills": [
			{"name": "Thousand Gaze", "kind": "mind", "power": 18, "w": 3, "msg": "stares at you from a thousand angles..."},
			{"name": "Hallucination", "kind": "status", "w": 2, "status": "hallu", "chance": 0.6, "msg": "makes the world spin!"},
			{"name": "Flash", "kind": "status", "w": 1, "status": "blind", "chance": 0.5, "msg": "blinks blindingly!"},
		]},
	"cacing": {"name": "Parasite Worm", "hp": 60, "atk": 15, "def": 2, "agi": 7, "exp": 32, "gold": [10, 20], "parts": "worm",
		"tags": ["flesh", "worm"], "loot": [["daging", 0.4], ["obat_cacing", 0.2]],
		"desc": "A giant worm with a ring of teeth. It lays eggs in wounds.",
		"skills": [
			{"name": "Egg Bite", "kind": "hit", "power": 1.0, "w": 4, "status": "parasite", "chance": 0.45, "msg": "bites and lays eggs in the wound!"},
			{"name": "Constrict", "kind": "hit", "power": 0.9, "w": 2, "status": "frac_arm", "chance": 0.25, "msg": "coils around your arm!"},
		]},
	"daging": {"name": "Walking Flesh", "hp": 86, "atk": 16, "def": 4, "agi": 3, "exp": 36, "gold": [16, 28], "parts": "human",
		"tags": ["flesh", "bloody"], "loot": [["daging_tumor", 0.5], ["w_gergaji", 0.04]],
		"desc": "A one-eyed lump of meat that walks like a man. It regrows.",
		"skills": [
			{"name": "Lump Slam", "kind": "hit", "power": 1.2, "w": 4, "status": "frac_leg", "chance": 0.25, "msg": "slams with a lumpy arm!"},
			{"name": "Flesh Hug", "kind": "hit", "power": 1.0, "w": 2, "status": "bleed", "chance": 0.5, "msg": "hugs you tight... its flesh sticks!"},
			{"name": "Regrow", "kind": "heal", "power": 0.18, "w": 1, "msg": "regrows its flesh!"},
		]},
	"spora": {"name": "Spore Sac", "hp": 50, "atk": 12, "def": 3, "agi": 2, "exp": 28, "gold": [10, 18], "parts": "blob",
		"tags": ["flesh"], "loot": [["herbal", 0.6], ["penawar", 0.25]],
		"desc": "A fungal sac that bursts into toxic clouds.",
		"skills": [
			{"name": "Spore Burst", "kind": "status", "w": 3, "status": "toxic", "chance": 0.55, "msg": "bursts into a purple spore cloud!"},
			{"name": "Spore Shot", "kind": "hit", "power": 0.8, "w": 2, "status": "poison", "chance": 0.5, "msg": "shoots spores!"},
		]},
	"bedah": {"name": "The Surgeon", "hp": 150, "atk": 18, "def": 5, "agi": 9, "exp": 100, "gold": [70, 110], "parts": "human",
		"tags": ["flesh", "bloody"], "elite": true, "loot": [["w_scalpel", 0.5], ["a_hazmat", 0.4], ["pisau_operasi", 1.0], ["obat_merah", 0.6]],
		"desc": "Scalpels for hands. It wants to operate on you. Without anesthesia.",
		"skills": [
			{"name": "Precise Cuts", "kind": "multi", "power": 0.55, "hits": 3, "w": 3, "status": "bleed", "chance": 0.4, "msg": "cuts with surgical precision!"},
			{"name": "Amputate", "kind": "hit", "power": 1.4, "w": 1, "status": "frac_arm", "chance": 0.5, "msg": "tries to amputate your arm!"},
			{"name": "Forced Sedation", "kind": "status", "w": 1, "status": "stun", "chance": 0.6, "msg": "injects a sedative!"},
		]},
	"boss_induk": {"name": "TUMOR MOTHER", "hp": 440, "atk": 20, "def": 6, "agi": 4, "exp": 400, "gold": [300, 400], "parts": "blob",
		"tags": ["flesh", "eye", "worm"], "boss": true, "big": true, "loot": [["batu_jiwa", 1.0]],
		"desc": "The heart of the Tumor Dimension. It gives birth endlessly.",
		"skills": [
			{"name": "Acid Spray", "kind": "hit", "power": 1.25, "w": 3, "status": "toxic", "chance": 0.55, "msg": "sprays stomach acid!"},
			{"name": "Give Birth", "kind": "summon", "summon": "tumor", "w": 1, "msg": "gives birth to tumor spawn!"},
			{"name": "Womb Scream", "kind": "mind", "power": 24, "w": 2, "msg": "screams with a thousand mouths!"},
			{"name": "Tentacles", "kind": "multi", "power": 0.5, "hits": 3, "w": 2, "status": "tumor", "chance": 0.35, "msg": "lashes out with tentacles!"},
		]},

	"mimic": {"name": "Mimic Chest", "hp": 60, "atk": 13, "def": 4, "agi": 5, "exp": 30, "gold": [40, 80], "parts": "beast",
		"tags": ["beast"], "loot": [["kunci", 0.5], ["dadu_emas", 0.3]],
		"desc": "Not every treasure chest wants to be opened.",
		"skills": [
			{"name": "Devour", "kind": "hit", "power": 1.3, "w": 3, "status": "bleed", "chance": 0.4, "msg": "BITES with wooden teeth!"},
			{"name": "Swallow Item", "kind": "steal_item", "w": 1, "msg": "swallows an item from your bag!"},
		]},
}

# -----------------------------------------------------------------------------
# SHOP STOCK per stage
# -----------------------------------------------------------------------------
const SHOP := {
	1: ["perban", "obat_merah", "bidai", "penawar", "roti", "nasi", "air", "kopi", "batu", "molotov", "kunci",
		"w_sapu", "w_pipa", "w_golok", "w_celurit", "a_jaket", "a_rompi", "a_helm", "x_jam", "x_masker", "x_sepatu"],
	2: ["perban", "obat_merah", "bidai", "penawar", "nasi", "air", "kopi", "garam", "air_suci", "jimat_kertas", "molotov", "bom_asap", "dadu_emas",
		"w_linggis", "w_pedang_tulang", "w_trisula", "w_tongkat", "a_rompi", "a_jubah", "a_zirah_tulang", "x_kalung", "x_kacamata", "x_cincin"],
	3: ["perban", "obat_merah", "bidai", "penawar", "jamu", "nasi", "obat_cacing", "obat_mata", "pisau_operasi", "jimat_kertas", "bom_asap", "dadu_emas",
		"w_kapak", "w_scalpel", "w_gergaji", "w_tongkat", "a_hazmat", "a_zirah_tulang", "x_masker", "x_cincin", "x_kacamata"],
}

const FIND_TABLE := {
	1: ["perban", "roti", "air", "kopi", "batu", "kain", "kayu", "tali", "paku", "botol", "minyak", "herbal", "permen", "kunci", "nasi", "bidai"],
	2: ["perban", "nasi", "air", "garam", "kain", "tali", "botol", "minyak", "herbal", "tanduk", "taring", "batu_jiwa", "penawar", "bidai", "jimat_kertas"],
	3: ["perban", "obat_merah", "jamu", "nasi", "herbal", "daging", "daging_tumor", "botol", "kain", "besi", "obat_cacing", "penawar", "bidai", "obat_mata"],
}

const TREASURE_TABLE := {
	1: ["w_pipa", "w_celurit", "a_jaket", "x_jam", "x_masker", "molotov", "bidai", "obat_merah", "kunci", "x_sepatu"],
	2: ["w_pedang_tulang", "w_linggis", "a_rompi", "a_jubah", "x_kalung", "x_kacamata", "air_suci", "dadu_emas", "bom_asap"],
	3: ["w_scalpel", "w_kapak", "a_hazmat", "x_cincin", "x_masker", "pisau_operasi", "obat_merah", "dadu_emas"],
}


func item(id: String) -> Dictionary:
	return ITEMS.get(id, {})


func item_name(id: String) -> String:
	return Loc.t(ITEMS.get(id, {}).get("name", id))


func item_icon(id: String) -> Texture2D:
	var p := GEN + "items/%s.png" % id
	if ResourceLoader.exists(p):
		return load(p)
	return load(GEN + "items/kantong.png")


func status_icon(id: String) -> Texture2D:
	var p := GEN + "status/%s.png" % id
	if ResourceLoader.exists(p):
		return load(p)
	return null


func icon(id: String) -> Texture2D:
	return load(GEN + "icons/%s.png" % id)


func enemy_tex(id: String, frame: int = 0) -> Texture2D:
	var p := GEN + "enemies/%s%s.png" % [id, "" if frame == 0 else "_2"]
	if ResourceLoader.exists(p):
		return load(p)
	return load(GEN + "enemies/preman.png")


func tile_icon(type: String) -> Texture2D:
	var p := GEN + "tiles/icon_%s.png" % type
	if ResourceLoader.exists(p):
		return load(p)
	return null


func status_name(id: String, stacks: int = 1) -> String:
	var s: Dictionary = STATUS.get(id, {})
	var n: String = Loc.t(s.get("name", id))
	if int(s.get("max", 1)) > 1:
		n += " " + roman(stacks)
	return n


func enemy_name(id: String) -> String:
	return Loc.t(ENEMIES.get(id, {}).get("name", id))


func part_name(part: Dictionary) -> String:
	return Loc.t(part.get("name", ""))


func tile_name(type: String) -> String:
	return Loc.t(TILE_INFO.get(type, {}).get("name", type))


func tile_desc(type: String) -> String:
	return Loc.t(TILE_INFO.get(type, {}).get("desc", ""))


func stage_name(st: int) -> String:
	return Loc.t(STAGES.get(st, {}).get("name", "Stage %d" % st))


func stage_sub(st: int) -> String:
	return Loc.t(STAGES.get(st, {}).get("sub", ""))


func roman(n: int) -> String:
	return ["", "I", "II", "III", "IV", "V", "VI"][clampi(n, 0, 6)]


func kind_label(kind: String) -> String:
	var en: String = {"consumable": "Consumables", "material": "Materials", "weapon": "Weapon", "armor": "Armor", "accessory": "Accessory"}.get(kind, kind)
	return Loc.t(en)


func skill_name(id: String) -> String:
	return Loc.t(SKILLS.get(id, {}).get("name", id))


func skill_desc(id: String) -> String:
	return Loc.t(SKILLS.get(id, {}).get("desc", ""))


func item_desc(id: String) -> String:
	return Loc.t(ITEMS.get(id, {}).get("desc", ""))


func status_desc(id: String) -> String:
	return Loc.t(STATUS.get(id, {}).get("desc", ""))


func status_cause(id: String) -> String:
	return Loc.t(STATUS.get(id, {}).get("cause", "-"))


func status_cure(id: String) -> String:
	return Loc.t(STATUS.get(id, {}).get("cure", "-"))


func enemy_desc(id: String) -> String:
	return Loc.t(ENEMIES.get(id, {}).get("desc", ""))


func stage_desc(st: int) -> String:
	return Loc.t(STAGES.get(st, {}).get("desc", ""))


func part_effect(brk: String) -> String:
	return Loc.t(PART_EFFECT.get(brk, ""))

