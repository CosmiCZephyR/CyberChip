extends Entity

class_name Enemy

var enemy_virus: Entity = Entity.new()

@export var path_to_player: NodePath = NodePath()

var _velocity: Vector2 = Vector2.ZERO

@onready var _timer: Timer = $Timer
@onready var _agent: NavigationAgent2D = $NavigationAgent2D
@onready var _player: Player = get_node(path_to_player)
@onready var _room: Area2D = get_parent()

#shock variables
var is_shocked = false
var shock_duration = 3
var speed = 50 

func  _ready() -> void:
	_timer.timeout.connect(self._update_pathfinding)
	_update_pathfinding()
	add_to_group("Enemies")

func _physics_process(delta):
	if _agent.is_navigation_finished():
		return

	var direction = global_position.direction_to(_agent.get_next_path_position())
	
	var desired_velocity = direction * speed 
	var steering = (desired_velocity - _velocity) * delta * 4.0
	_velocity += steering
	
	set_velocity(_velocity)
	move_and_slide()

func _process(_delta):
	if current_health <= 0:
		queue_free()

func _update_pathfinding() -> void:
	await get_tree().create_timer(1).timeout
	var bodies = _room.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			_agent.set_target_position(_player.global_position)

func apply_shock() -> void:
	if not is_shocked:
		is_shocked = true
		speed = 0
		await get_tree().create_timer(shock_duration).timeout
		speed = 50
		is_shocked = false
