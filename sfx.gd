extends Node

@export var master_volume: float = 0.7

var sound_groups: Dictionary = {}
var camera_bridge: Node

func _ready():
	camera_bridge = get_node("/root/CameraBridge")
	find_sound_groups(self)
	
	for sound_group in sound_groups.values():
		sound_group.initialize(self)
	
	print_rich("[SFX] [color=MediumSeaGreen]Ready[/color] with ", sound_groups.size(), " sound groups")

func find_sound_groups(node: Node):
	sound_groups.clear()
	for child in node.get_children():
		if child is SoundGroup3D:
			sound_groups[child.name] = child
		else:
			find_sound_groups(child)

func play(sound_group_name: String):
	play_sound(sound_group_name, camera_bridge.camera_position)

func play_sound(sound_group_name: String, location: Vector3 = Vector3.ZERO):
	if location == Vector3.ZERO:
		location = camera_bridge.camera_position
	
	if not sound_groups.has(sound_group_name):
		print("[SFX] Requested a sound group that does not exist: ", sound_group_name)
		return
	
	var sound_group = sound_groups[sound_group_name]
	var source = sound_group.get_available_source()
	
	if source:
		if source.playing:
			print("Sound group is already playing")
		print("[SFX] Playing: ", sound_group_name)
		source.position = location
		source.play()
