extends Node
class_name SFXManager2D

var sound_groups: Dictionary = {}

func _ready():
	for child in get_children():
		if child is AudioStreamPlayer:
			sound_groups[child.name] = child
	
	print_rich("[SFX2D] [color=MediumSeaGreen]Ready[/color] with ", sound_groups.size(), " sound groups")

func play_sound(sound_group_name: String):
	if sound_groups.has(sound_group_name):
		var player = sound_groups[sound_group_name]
		if player:
			print("[SFX2D] Playing: ", sound_group_name)
			player.play()
	else:
		print("[SFX2D] Requested a sound group that does not exist: ", sound_group_name)
