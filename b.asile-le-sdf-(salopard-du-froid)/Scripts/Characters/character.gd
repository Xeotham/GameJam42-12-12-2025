extends CharacterBody2D

@export var health : int
@export var damage : int
@export var speed : int

@onready var animation_player := $AnimationPlayer
@onready var character_sprite := $CharacterSprite
@onready var damage_emmiter := $DamageEmitter

enum States {
	IDLE,
	WALK,
	ATTACK
}

var state = States.IDLE

func _ready() -> void:
	damage_emmiter.area_entered.connect(on_emit_damage.bind())

func _process(_delta: float) -> void:
	handle_input()
	handle_movement()
	handle_animation()
	flip_sprite()
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = States.IDLE
		else:
			state = States.WALK

func handle_input() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("Attack"):
		state = States.ATTACK

func handle_animation() -> void:
	if state == States.IDLE:
		animation_player.play("idle")
	elif state == States.WALK:
		animation_player.play("walk")
	elif state == States.ATTACK:
		animation_player.play("Punch")

func flip_sprite() -> void:
	if velocity.x > 0:
		character_sprite.flip_h = false
		damage_emmiter.scale.x = 1
	elif velocity.x < 0:
		character_sprite.flip_h = true
		damage_emmiter.scale.x = -1

func can_move() -> bool:
	return state == States.IDLE or state == States.WALK

func can_attack() -> bool:
	return state == States.IDLE or state == States.WALK

func on_action_complete() -> void:
	state = States.IDLE

func on_emit_damage(damage_receiver: DamageReceiver) -> void:
	var direction := Vector2.LEFT if damage_receiver.global_position.x < global_position.x else Vector2.RIGHT
	damage_receiver.damage_received.emit(damage, direction)
	print(damage_receiver)
