class_name DamageReceiver
extends Area2D

enum HitType {
	NORMAL,
	KNOCKDOWN,
	POWER,
	SPECIAL,
	NONE
}

signal damage_received(damage: int, direction: Vector2, hit_type: HitType)
