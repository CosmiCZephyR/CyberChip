class_name Enemy
extends Entity

@warning_ignore("unused_private_class_variable")
var _velocity: Vector2 = Vector2.ZERO

@onready var _timer: Timer = $Timer
@onready var _agent: NavigationAgent2D = $NavigationAgent2D
@onready var _player: Player = get_parent().get_parent().get_node("Player")
@onready var _room: Area2D = get_parent()

# shock variables
var is_shocked: bool = false
var shock_duration: float = 3
var speed: float = 50 

# room's corners
var first_corner: Vector2
var second_corner: Vector2

# signals
signal following_started
signal following_finished
signal zone_exited
signal attack_released

func _ready() -> void:
	max_health = 100
	current_health = 50
	_timer.timeout.connect(self._update_pathfinding)
	add_to_group("Enemies")

func _process(_delta):
	first_corner = _room.get_node("Marker2D").global_position
	second_corner = _room.get_node("Marker2D2").global_position
	
	if current_health <= 0:
		queue_free()

func _update_pathfinding() -> void:
	await get_tree().create_timer(0.1).timeout
	var bodies = _room.get_overlapping_bodies()
	for body in bodies:
		if body is Player:
			_agent.set_target_position(_player.global_position)
			emit_signal("following_started")

func apply_shock() -> void:
	if not is_shocked:
		return
	
	is_shocked = true
	speed = 0
	await get_tree().create_timer(shock_duration).timeout
	speed = 50
	is_shocked = false
