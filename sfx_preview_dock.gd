@tool
extends Control

var current_scene: Node = null
var sfx_node: Node = null
var sound_groups: Dictionary = {}
var sound_categories: Dictionary = {}

var refresh_button: Button
var sound_container: HBoxContainer

func _ready():
	name = "SFX Preview"
	
	setup_ui()
	refresh_scene_context()

func setup_ui():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(scroll_container)
	
	sound_container = HBoxContainer.new()
	sound_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sound_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(sound_container)

func refresh_scene_context():
	current_scene = EditorInterface.get_edited_scene_root()
	check_scene_validity()
	
	if is_valid_sfx_scene():
		sfx_node = current_scene
		scan_for_sound_groups()
		rebuild_sound_list()
	else:
		clear_sound_groups()
		show_scene_status()

func check_scene_validity():
	if not current_scene:
		print("[SFXPreviewDock] No scene open")
		return
	
	if current_scene.name != "SFX":
		print("[SFXPreviewDock] Open scene with root node named SFX")
		return
	
	print("[SFXPreviewDock] SFX scene detected")

func is_valid_sfx_scene() -> bool:
	return current_scene != null and current_scene.name == "SFX"

func scan_for_sound_groups():
	sound_groups.clear()
	sound_categories.clear()
	
	scan_node_recursive(sfx_node, "Root")

func scan_node_recursive(node: Node, category: String):
	for child in node.get_children():
		var script = child.get_script()
		if script:
			if child is SoundGroup3D:
				if is_valid_sound_group(child):
					sound_groups[child.name] = child
					sound_categories[child.name] = category
		
		if child.get_child_count() > 0:
			var child_category = child.name if child.name != "SFX" else category
			scan_node_recursive(child, child_category)

func is_valid_sound_group(sound_group: Node) -> bool:
	for child in sound_group.get_children():
		if child is AudioStreamPlayer3D and child.stream != null:
			return true
	return false

func clear_sound_groups():
	sound_groups.clear()
	sound_categories.clear()
	clear_sound_container()

func rebuild_sound_list():
	clear_sound_container()
	
	if sound_groups.is_empty():
		show_no_sounds_in_scene()
		return
	
	update_status_with_count()
	var categories = get_organized_categories()
	create_column_layout(categories)

func clear_sound_container():
	for child in sound_container.get_children():
		sound_container.remove_child(child)
		child.queue_free()

func show_scene_status():
	var label = Label.new()
	label.text = "Open a scene with root node named 'SFX' to preview sounds"
	label.modulate = Color.GRAY
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sound_container.add_child(label)

func show_no_sounds_in_scene():
	var label = Label.new()
	label.text = "No valid sound groups found in SFX scene"
	label.modulate = Color.ORANGE
	sound_container.add_child(label)

func update_status_with_count():
	
	print("[SFXPreviewDock] Found " + str(sound_groups.size()) + " sound groups")

func get_organized_categories() -> Dictionary:
	var categories = {}
	
	for sound_name in sound_groups.keys():
		var category = sound_categories.get(sound_name, "Uncategorized")
		if not categories.has(category):
			categories[category] = []
		categories[category].append(sound_name)
	
	for category in categories.keys():
		categories[category].sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	return categories

func create_column_layout(categories: Dictionary):
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sound_container.add_child(hbox)
	
	var sorted_categories = categories.keys()
	sorted_categories.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	
	for category in sorted_categories:
		if categories[category].size() > 0:
			create_category_column(hbox, category, categories[category])

func create_category_column(parent: HBoxContainer, category_name: String, sound_names: Array):
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	
	var header = Label.new()
	header.text = category_name
	header.add_theme_font_size_override("font_size", 12)
	header.modulate = Color.CYAN
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(header)
	
	var separator = HSeparator.new()
	column.add_child(separator)
	
	for sound_name in sound_names:
		var button = Button.new()
		button.text = sound_name
		button.pressed.connect(play_sound_preview.bind(sound_name))
		column.add_child(button)

func play_sound_preview(sound_name: String):
	if not sound_groups.has(sound_name):
		print("Sound group not found: ", sound_name)
		return
	
	var sound_group = sound_groups[sound_name]
	var audio_players = get_audio_players(sound_group)
	
	if audio_players.is_empty():
		print("No valid audio players in ", sound_name)
		return
	
	var random_player = audio_players[randi() % audio_players.size()]
	random_player.play()
	print("SFX Preview: Playing ", sound_name, " (", audio_players.size(), " variations)")

func get_audio_players(sound_group: Node) -> Array:
	var players = []
	for child in sound_group.get_children():
		if child is AudioStreamPlayer3D and child.stream != null:
			players.append(child)
	return players
