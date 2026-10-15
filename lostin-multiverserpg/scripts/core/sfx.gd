extends Node
## Sound effects + looping ambient music. Autoload name: Sfx

const DIR := "res://assets/gen/audio/"
var players: Array[AudioStreamPlayer] = []
var cache: Dictionary = {}
var music_a: AudioStreamPlayer
var music_b: AudioStreamPlayer
var current_music := ""
var sfx_db := -6.0
var music_db := -14.0
var muted := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	music_a = AudioStreamPlayer.new()
	music_b = AudioStreamPlayer.new()
	add_child(music_a)
	add_child(music_b)
	music_a.finished.connect(func(): if music_a.stream: music_a.play())
	music_b.finished.connect(func(): if music_b.stream: music_b.play())


func _stream(name_: String) -> AudioStream:
	if cache.has(name_):
		return cache[name_]
	var p := DIR + name_ + ".wav"
	var s: AudioStream = null
	if ResourceLoader.exists(p):
		s = load(p)
	cache[name_] = s
	return s


func play(name_: String, pitch_var: float = 0.08, vol: float = 0.0) -> void:
	if muted:
		return
	var s := _stream(name_)
	if s == null:
		return
	for p in players:
		if not p.playing:
			p.stream = s
			p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
			p.volume_db = sfx_db + vol
			p.play()
			return
	players[0].stream = s
	players[0].play()


func music(name_: String, fade: float = 1.0) -> void:
	if name_ == current_music:
		return
	current_music = name_
	var s := _stream(name_)
	var out_p := music_a if music_a.playing else music_b
	var in_p := music_b if out_p == music_a else music_a
	var tw := create_tween().set_parallel(true)
	tw.tween_interval(fade)
	if out_p.playing:
		tw.tween_property(out_p, "volume_db", -60.0, fade)
	if s:
		in_p.stream = s
		in_p.volume_db = -60.0
		in_p.play()
		tw.tween_property(in_p, "volume_db", -80.0 if muted else music_db, fade)
	await tw.finished
	if out_p.playing and out_p != in_p:
		out_p.stop()
		out_p.stream = null


func toggle_mute() -> void:
	muted = not muted
	for p in [music_a, music_b]:
		if p.playing:
			p.volume_db = -80.0 if muted else music_db
