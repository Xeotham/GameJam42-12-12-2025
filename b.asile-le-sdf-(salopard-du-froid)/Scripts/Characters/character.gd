extends CharacterBody2D

@export var health : int
@export var damage : int
@export var speed : int

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite

enum States {
	IDLE,
	WALK
}

var state = States.IDLE

func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	flip_sprite()
	move_and_slide()

func handle_movement() -> void:
	if velocity.length() == 0:
		state = States.IDLE
	else:
		state = States.WALK

func handle_input() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed

func handle_animation() -> void:
	if state == States.IDLE:
		animation_player.play("idle")
	elif state == States.WALK:
		animation_player.play("walk")

func flip_sprite() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true
