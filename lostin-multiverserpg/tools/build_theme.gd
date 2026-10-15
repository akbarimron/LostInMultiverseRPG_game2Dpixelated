extends SceneTree
## Dev helper: bakes ThemeBuilder output into a .tres used as the project-wide theme.
func _init() -> void:
	var t: Theme = ThemeBuilder.build()
	var err := ResourceSaver.save(t, "res://assets/gen/ui/pixel_theme.tres")
	print("theme saved: ", err)
	quit()
