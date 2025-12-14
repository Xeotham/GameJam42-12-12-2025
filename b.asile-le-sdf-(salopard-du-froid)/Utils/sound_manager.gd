class_name SoundManager
extends Node

@onready var sounds : Array[AudioStreamPlayer] = [
	$Burp,
	$Fart,
	$Sneeze
]

enum Sound {
	BURP,
	FART,
	SNEEZE
}

func play(sfx: Sound, tweak_pitch: bool = false) -> void:
	var added_pitch := 0
	if tweak_pitch:
		added_pitch = randf_range(-0.3, 0.3)
	sounds[sfx as int].pitch_scale = 1 + added_pitch
	sounds[sfx as int].play()
