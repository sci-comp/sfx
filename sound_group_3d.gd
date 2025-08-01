extends Node
class_name SoundGroup3D

@export var max_voices: int = 3
@export var vary_pitch: Vector2 = Vector2(0.97, 1.03)
@export var vary_volume: Vector2 = Vector2(0.95, 1.0)

var available_sources: Array[AudioStreamPlayer3D] = []
var active_sources: Array[AudioStreamPlayer3D] = []
var sfx: Node

var total_variations: int:
	get:
		return active_sources.size() + available_sources.size()

func initialize(_sfx: Node):
	sfx = _sfx
	
	for child in get_children():
		if child is AudioStreamPlayer3D:
			child.finished.connect(_on_audio_finished.bind(child))
			available_sources.append(child)
	
	if max_voices > available_sources.size():
		max_voices = available_sources.size()

func _on_audio_finished(src: AudioStreamPlayer3D):
	active_sources.erase(src)
	available_sources.append(src)

func stop_source(src: AudioStreamPlayer3D):
	src.stop()
	active_sources.erase(src)
	available_sources.append(src)

func get_available_source() -> AudioStreamPlayer3D:
	var src: AudioStreamPlayer3D
	
	# Stop an active source if necessary
	if available_sources.size() == 0 or active_sources.size() >= max_voices:
		src = active_sources[0]
		stop_source(src)
	
	var idx = randi() % available_sources.size()
	src = available_sources[idx]
	src.pitch_scale = randf_range(vary_pitch.x, vary_pitch.y)
	src.volume_db = linear_to_db(randf_range(vary_volume.x, vary_volume.y))
	available_sources.remove_at(idx)
	active_sources.append(src)
	
	return src
