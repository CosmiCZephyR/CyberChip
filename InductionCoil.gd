extends StaticBody2D

@onready var _player = get_tree().get_first_node_in_group("Player")
@onready var _timer = $Timer
@onready var _line = $Line2D
@onready var _area = $Area2D

var bodies: Array[Node2D]

var player_in_area: bool = false

func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)

func _process(_delta) -> void:
	bodies = _area.get_overlapping_bodies()
	
	if player_in_area:
		_line.points[5] = to_local(_player.global_position)
	else:
		_line.points[5] = Vector2(64, 0)

func _on_timer_timeout() -> void:
	for body in bodies:
		if body.is_in_group("Player"):
			player_in_area = true
			create_lightning()
		elif bodies.size() == 0:
			player_in_area = false

func create_lightning() -> void:
	for point in range(1, _line.points.size() - 1):
		_line.points[point].y = randi_range(-16, 16)
