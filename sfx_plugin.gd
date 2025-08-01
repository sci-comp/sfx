@tool
extends EditorPlugin

var dock

func _enter_tree():
	dock = preload("res://addons/sfx/sfx_preview_dock.gd").new()
	add_control_to_bottom_panel(dock, "SFX")
func _exit_tree():
	if dock:
		remove_control_from_bottom_panel(dock)
		dock = null
	
	
