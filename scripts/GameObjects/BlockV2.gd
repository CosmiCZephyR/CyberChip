extends RigidBody2D

var can_magnetic = true

func _ready():
	SaveManager.register_object(self)
	mass = 0.0001
	gravity_scale = 0
	add_to_group("magnetic")
