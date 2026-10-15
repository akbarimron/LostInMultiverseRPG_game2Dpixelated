extends Node
## Dev helper: loads every game script so compile errors are printed (run headless).

func _ready() -> void:
	var files := []
	_collect("res://scripts", files)
	var bad := 0
	for f in files:
		var s = load(f)
		if s == null or (s is GDScript and not (s as GDScript).can_instantiate()):
			print("FAIL ", f)
			bad += 1
	print("CHECKED %d scripts, %d failed" % [files.size(), bad])
	get_tree().quit()


func _collect(dir: String, out: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir + "/" + f)
	for sub in d.get_directories():
		_collect(dir + "/" + sub, out)
