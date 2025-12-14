class_name Player
extends Character

signal healthChanged

@onready var enemy_slots : Array = $EnemySlots.get_children()

var hit_sound = [SoundManager.Sound.BURP, SoundManager.Sound.FART]

func _ready() -> void:
	super._ready()
	anim_attacks = ["Punch", "Punch_alt", "Kick", "Roundkick"]
	anim_specials = ["Special"]

func handle_input() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	if can_attack():
		if Input.is_action_just_pressed("Attack"):
			hit_sound.shuffle()
			SoundPlayer.play(hit_sound[0], true)
			state = States.ATTACK
			if is_last_hit_succesful:
				attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
				is_last_hit_succesful = false
			else:
				attack_combo_index = 0
		elif Input.is_action_just_pressed("Special"):
			SoundPlayer.play(SoundManager.Sound.SNEEZE, true)
			state = States.SPECIAL
			is_last_hit_succesful = false
			

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func reserve_slots(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]
	
func free_slots(enemy: BasicEnemy) -> void:
	var target_slot := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slot.size() == 1:
		target_slot[0].free_up()

func on_receive_damage(amount: int, direction: Vector2, hit_type: DamageReceiver.HitType) -> void:
	super.on_receive_damage(amount, direction, hit_type)
	healthChanged.emit()
	print(current_health)
