class_name Entity
extends CharacterBody2D

signal damage_applied
signal health_healed

signal kosuki_changed

var movement: Vector2 = Vector2.ZERO

# Health variables

var max_health: int = 150
var current_health: int = 100
var health_regen: int = 1
var armor: int = 0

# Kosuki (energy + mana + cosmos + japanese) variables

var max_kosuki: int = 200
var current_kosuki: int = 100
var kosuki_regen: int = 1

# misc

var frame_count: int = 0
var is_busy: bool = false
var last_ability: int = 0

func regen_health():
	if current_health < max_health:
		if (health_regen + current_health) > max_health:
			current_health = max_health
		else:
			current_health += health_regen
	
	if current_health % 25 == 0:
		emit_signal("health_healed")

func regen_kosuki():
	if current_kosuki < max_kosuki:
		if (kosuki_regen + current_kosuki) > max_kosuki:
			current_kosuki = max_kosuki
		else:
			current_kosuki += kosuki_regen

func modify_kosuki(amount):
	var new_kosuki = current_kosuki + amount
	
	if new_kosuki < 0:
		current_kosuki = 0
	
	if new_kosuki > max_kosuki:
		current_kosuki = max_kosuki
	
	else: current_kosuki += amount

func apply_damage(amount):
	emit_signal("damage_applied")
	
	if armor > 0:
		amount = amount * ((100 - armor) * 0.01)
	
	if current_health > amount:
		current_health -= amount
	
	else:
		print("death")

func _physics_process(_delta):
	frame_count += 1
	last_ability += 1
	if (frame_count % 60) == 0:
		regen_health()
		regen_kosuki()

func load_ability(scene_name):
	var scene = load("res://Abilities/" + scene_name + "/" + scene_name + ".tscn")
	var sceneNode = scene.instantiate()
	add_child(sceneNode)
	return sceneNode
