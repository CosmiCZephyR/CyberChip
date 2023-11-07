extends StaticBody2D

@onready var _player = get_tree().get_first_node_in_group("Player")
@onready var _timer = $Timer
@onready var _line = $Line2D
@onready var _area = $Area2D

var bodies: Array[Node2D]

var visibility: bool = false
var player_in_area: bool = false
var last_point_pos: Vector2 = Vector2(0, 64)

func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)

func _process(_delta) -> void:
	bodies = _area.get_overlapping_bodies()

func _on_timer_timeout() -> void:
	_line.set_visible(visibility)
	
	for body in bodies:
		_line.points[5] = last_point_pos
		
		if body.is_in_group("Player"):
			create_lightning()

func create_lightning() -> void:
	for point in range(1, _line.points.size() - 1):
		_line.points[point].y = randi_range(-16, 16)
	
	visibility = true
	last_point_pos = to_local(_player.global_position)
