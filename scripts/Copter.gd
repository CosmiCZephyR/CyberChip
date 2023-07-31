extends Node2D

@onready var bullet_scene = preload("res://scenes/bullet.tscn")

var bullet

func _ready() -> void:
	pass

func _physics_process(_delta) -> void:
	shoot()

func shoot():
	if Input.is_action_just_pressed("copterAttack"):
#		await create_tween().interpolate_value(position, Vector2(position.x + 20, position.y + 7), 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		bullet = bullet_scene.instantiate()
		get_parent().get_parent().add_child(bullet)
		bullet.global_position = $Marker2D.global_position
