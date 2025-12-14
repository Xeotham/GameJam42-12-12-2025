class_name Character
extends CharacterBody2D

const	GRAVITY := 600.0

@export var max_health : int
@export var type: Type
@export var duration_grounded : float
@export var damage : int
@export var damage_power : int
@export var knockback_intensity : float
@export var knockdown_intensity : float
@export var speed : int
@export var jump_intensity: float
@export var flight_speed: float
@export var can_respawn: bool

@onready var animation_player := $AnimationPlayer
@onready var collateral_damage_emmiter : Area2D= $CollateralDamageEmitter
@onready var character_sprite := $CharacterSprite
@onready var collision_shape := $CollisionShape2D
@onready var damage_emmiter := $DamageEmitter
@onready var damage_receiver : DamageReceiver = $DamageReceiver

enum States {
	IDLE,
	WALK,
	ATTACK,
	TAKEOFF,
	JUMP,
	LAND,
	JUMPKICK,
	HURT,
	FALL,
	GROUNDED,
	DEATH,
	FLY,
	PREP_ATTACK
}

var anim_attacks := []
var anim_map : Dictionary = {
	States.IDLE:		"Idle",
	States.WALK:		"Walk",
	States.TAKEOFF:		"Takeoff",
	States.JUMP:		"Jump",
	States.LAND:		"Landing",
	States.JUMPKICK:	"Jumpkick",
	States.HURT:		"Hurt",
	States.FALL:		"Fall",
	States.GROUNDED:	"Grounded",
	States.DEATH:		"Grounded",
	States.FLY:			"Fly",
	States.PREP_ATTACK:	"Idle"
}

var attack_combo_index := 0

var state = States.IDLE
var height := 0.0
var height_speed := 0.0
var current_health := 0
var heading := Vector2.RIGHT
var time_since_grounded := Time.get_ticks_msec()
var is_last_hit_succesful := false


func _ready() -> void:
	damage_emmiter.area_entered.connect(on_emit_damage.bind())
	damage_receiver.damage_received.connect(on_receive_damage.bind())
	collateral_damage_emmiter.area_entered.connect(on_emit_collateral_damage.bind())
	collateral_damage_emmiter.body_entered.connect(on_wall_hit.bind())
	current_health = max_health

func _process(delta: float) -> void:
	handle_input()
	handle_movement()
	handle_prep_attack()
	handle_animation()
	handle_airtime(delta)
	handle_grounded()
	handle_death(delta)
	set_heading()
	flip_sprite()
	character_sprite.position = Vector2.UP * height
	collision_shape.disabled = is_collision_disabled()
	move_and_slide()

func handle_movement() -> void:
	if can_move():
		if velocity.length() == 0:
			state = States.IDLE
		else:
			state = States.WALK

func handle_input() -> void:
	pass

func handle_prep_attack() -> void:
	pass

func handle_animation() -> void:
	if state == States.ATTACK:
		animation_player.play(anim_attacks[attack_combo_index])
	elif animation_player.has_animation(anim_map[state]):
		animation_player.play(anim_map[state])

func handle_airtime(delta: float) -> void:
	if [States.JUMP, States.JUMPKICK, States.FALL].has(state):
		height += height_speed * delta
	if height < 0:
		height = 0
		if state == States.FALL:
			state = States.GROUNDED
			time_since_grounded = Time.get_ticks_msec()
		else:
			state = States.LAND
		velocity = Vector2.ZERO
	else:
		height_speed -= GRAVITY * delta

func handle_grounded() -> void:
	if state == States.GROUNDED and (Time.get_ticks_msec() - time_since_grounded) > duration_grounded:
		if current_health == 0:
			state = States.DEATH
		else:
			state = States.LAND

func handle_death(delta: float) -> void:
	if state == States.DEATH and not can_respawn:
		modulate.a -= delta / 2.0
		if modulate.a <= 0:
			queue_free()

func set_heading() -> void:
	pass

func flip_sprite() -> void:
	if heading == Vector2.RIGHT:
		character_sprite.flip_h = false
		damage_emmiter.scale.x = 1
	else:
		character_sprite.flip_h = true
		damage_emmiter.scale.x = -1

func can_move() -> bool:
	return state == States.IDLE or state == States.WALK

func can_attack() -> bool:
	return state == States.IDLE or state == States.WALK

func can_jump() -> bool:
	return state == States.IDLE or state == States.WALK

func can_jumpkick() -> bool:
	return state == States.JUMP

func can_get_hurt() -> bool:
	return [States.IDLE, States.WALK, States.TAKEOFF, States.JUMP, States.LAND].has(state)

func is_collision_disabled() -> bool:
	return [States.GROUNDED, States.DEATH, States.FLY].has(state)

func on_action_complete() -> void:
	state = States.IDLE

func on_takeoff_complete():
	state =  States.JUMP
	height_speed = jump_intensity
	
func on_land_complete():
	state = States.IDLE

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	if can_get_hurt():
		current_health = clamp(current_health - amount, 0, max_health)
		if current_health == 0 or hit_type == DamageReceiver.HitType.KNOCKDOWN:
			state = States.FALL
			height_speed = knockdown_intensity
			velocity = direction * knockback_intensity
		elif hit_type == DamageReceiver.HitType.POWER:
			state = States.FLY
			velocity = direction * flight_speed
		else:
			state = States.HURT
			velocity = direction * knockback_intensity

func on_emit_damage(receiver: DamageReceiver) -> void:
	var hit_type := DamageReceiver.HitType.NORMAL
	var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
	var current_damage = damage
	if state == States.JUMPKICK:
		hit_type = DamageReceiver.HitType.KNOCKDOWN
	if attack_combo_index == anim_attacks.size() - 1:
		hit_type = DamageReceiver.HitType.POWER
		current_damage = damage_power
	receiver.damage_received.emit(current_damage, direction, hit_type)
	is_last_hit_succesful = true
	
func on_emit_collateral_damage(receiver: DamageReceiver) -> void:
	if receiver != damage_receiver:
		var direction := Vector2.LEFT if receiver.global_position.x < global_position.x else Vector2.RIGHT
		receiver.damage_received.emit(0, direction, DamageReceiver.HitType.KNOCKDOWN)
	
func on_wall_hit(_wall: AnimatableBody2D) -> void:
	state = States.FALL
	height_speed = knockdown_intensity
	velocity = -velocity / 2.0
