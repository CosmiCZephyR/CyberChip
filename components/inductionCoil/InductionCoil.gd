extends StaticBody2D

@onready var _player = get_tree().get_first_node_in_group("Player")
@onready var _line_rotator = $LineRotator
@onready var _line = $LineRotator/Line2D
@onready var _area = $Area2D
@onready var _timer = $Timer

var bodies: Array[Node2D]

var visibility: bool = false
var player_in_area: bool = false
var last_point_pos: Vector2 = Vector2(0, 64)

func _ready() -> void:
	_line.set_visible(false)
	SaveManager.register_object(self)
	#_decrease_distance_by(7)
	_timer.timeout.connect(_on_timer_timeout)
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)

func _process(_delta) -> void:
	bodies = _area.get_overlapping_bodies()

func _on_timer_timeout():
	for body in bodies:
		if body is Player:
			create_lightning()

func _on_body_entered(body):
	_line.set_visible(true)

func _on_body_exited(_body) -> void:
	_line.set_visible(false)

func create_lightning() -> void:
	for point in range(1, _line.get_point_count() - 1):
		_line.points[point].y = randi_range(-12, 12)
	
	visibility = true
	_line_rotator.look_at(_player.global_position)

func _decrease_distance_by(x: int) -> void:
	var tmp = x / 7
	
	for point in range(1, _line.get_point_count()):
		_line.points[point].x -= tmp
	
