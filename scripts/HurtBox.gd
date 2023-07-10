extends Area2D

class_name HurtBox

func _init():
	collision_layer = 2
	collision_mask = 1

func _ready():
	area_entered.connect(self._on_area_entered)

func _on_area_entered(hitbox: AttackHitBox):
	if hitbox == null: return
	if hitbox.owner == owner: return
	
	if owner.has_method("apply_damage"):
		owner.apply_damage(hitbox.damage)
