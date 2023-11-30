class_name HealthComponent
extends Node

signal health_increased
signal damage_applied

var current_health: int
var health_regen: int 
var max_health: int

var is_dead: bool = false

func heal(amount: int) -> int:
	current_health += amount
	
	if current_health >= max_health:
		current_health += max_health
	else:
		current_health += amount
	
	emit_signal("health_increased")
	return current_health

func apply_damage(damage: int) -> int:
	current_health -= damage
	
	if current_health <= 0:
		is_dead = true
	else:
		current_health -= damage
	
	emit_signal("damage_applied")
	return current_health

func set_max_health() -> int:
	current_health = max_health
	return current_health
