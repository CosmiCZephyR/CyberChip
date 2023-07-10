extends Area2D

class_name AttackHitBox

@export var damage = 10

func _init():
	collision_layer = 1
	collision_mask = 0
