extends Area2D

class_name Diode

enum States {PERMANENT_LASER, VARIABLE_LASER, PERMANENT_LIGHT, VARIABLE_LIGHT}

var current_state = States.PERMANENT_LASER

@onready var _laser_scene = preload("res://components/diode/laser_bullet.tscn")
@onready var _timer_cooldown: Timer = $LaserCooldown
@onready var _ray: RayCast2D = $RayCast2D
@onready var _line: Line2D = $Line2D

var laser

func _ready():
	_line.visible = false

func _physics_process(_delta):
	variable_laser()

# постоянный лазер
func permanent_laser() -> void:
	_line.visible = true
	_ray.force_raycast_update()
	
	if _ray.collide_with_areas:
		_line.points[1] = _ray.to_local(_ray.get_collision_point())

# переменный лазер
func variable_laser() -> void:
	_ray.force_raycast_update()
	
	await _timer_cooldown.timeout
	laser = _laser_scene.instantiate()
	add_child(laser)
	laser.global_position = $Marker2D.global_position

# постоянный фонарь
func permanent_light() -> void:
	pass

# пременный фонарь
func variable_light() -> void:
	pass
