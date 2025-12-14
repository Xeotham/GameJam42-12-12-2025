class_name Stage
extends Node2D

@export var music : MusicManager.Music

func _ready() -> void:
	MusicPlayer.play(music)
