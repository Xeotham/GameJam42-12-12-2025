class_name UI
extends CanvasLayer

const DEATH_SCREEN_PREFAB := preload("res://Scenes/Gui/death_screen.tscn")

var death_screen : DeathScreen = null
@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.healthChanged.connect(on_character_health_change.bind())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_character_health_change() -> void:
	if player.current_health == 0 and death_screen == null:
		death_screen = DEATH_SCREEN_PREFAB.instantiate()
		add_child(death_screen)
	pass
