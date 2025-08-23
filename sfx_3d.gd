extends Node
class_name SFXManager3D

var sound_groups: Dictionary = {}
var main_camera: Camera3D

func _ready():
	sound_groups.clear()
	find_sound_groups(self)
	find_main_camera()
	
	for sound_group in sound_groups.values():
		sound_group.initialize()
	
	print_rich("[SFX] [color=MediumSeaGreen]Ready[/color] with ", sound_groups.size(), " sound groups")

func find_main_camera():
	var cameras = get_tree().get_nodes_in_group("MainCamera")
	if cameras.size() > 0:
		main_camera = cameras[0]
		print("[SFX] Found main camera: ", main_camera.name)
	else:
		print("[SFX] No MainCamera group found")

func set_main_camera(camera: Camera3D):
	main_camera = camera
	print("[SFX] Main camera set to: ", camera.name)

func get_camera_position() -> Vector3:
	if main_camera:
		return main_camera.global_position
	return Vector3.ZERO

func play(sound_group_name: String):
	play_sound(sound_group_name, get_camera_position())

func play_sound(sound_group_name: String, location: Vector3 = Vector3.INF):
	location = get_camera_position()
	
	if sound_groups.has(sound_group_name):
		var sound_group = sound_groups[sound_group_name]
		var source = sound_group.get_available_source()
		if source:
			source.global_position = location
			source.play()
	else:
		print("[SFX] Sound group not found: ", sound_group_name)

func find_sound_groups(node: Node):
	for child in node.get_children():
		if child is SoundGroup3D:
			sound_groups[child.name] = child
		else:
			find_sound_groups(child)
