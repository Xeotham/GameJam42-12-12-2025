class_name BasicEnemy
extends Character

@export var duration_between_hits: int
@export var duration_prep_hit : int
@export var player: Player

var player_slot: EnemySlot = null
var time_since_last_hit := Time.get_ticks_msec()
var time_since_prep_hit := Time.get_ticks_msec()

func _ready() -> void:
	super._ready()
	anim_attacks = ["Punch", "Punch_alt"]

func handle_input() -> void:
	if player != null and can_move():
		if player_slot == null:
			player_slot = player.reserve_slots(self)
		if player_slot != null:
			var direction := (player_slot.global_position - global_position).normalized()
			if is_player_within_range():
				velocity = Vector2.ZERO
				if can_attack():
					state = States.PREP_ATTACK
					time_since_prep_hit = Time.get_ticks_msec()
			else:
				velocity = direction * speed

func is_player_within_range() -> bool:
	return (player_slot.global_position - global_position).length() < 1

func handle_prep_attack() -> void:
	if state == States.PREP_ATTACK and (Time.get_ticks_msec() - time_since_prep_hit) > duration_prep_hit:
		state = States.ATTACK
		time_since_last_hit = Time.get_ticks_msec()
		anim_attacks.shuffle()

func set_heading() -> void:
	if player == null:
		return
	if position.x > player.position.x:
		heading = Vector2.LEFT
	else:
		heading = Vector2.RIGHT

func can_attack() -> bool:
	if Time.get_ticks_msec() - time_since_last_hit < duration_between_hits:
		return false
	return super.can_attack()

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(amount, direction, hit_type)
	if current_health == 0:
		player.free_slots(self)
