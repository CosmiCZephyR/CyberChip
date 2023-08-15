extends Entity

class_name Enemy

var enemy_virus: Entity = Entity.new()

var _velocity: Vector2 = Vector2.ZERO

@onready var _timer: Timer = $Timer
@onready var _agent: NavigationAgent2D = $NavigationAgent2D
@onready var _player: Player = get_tree().get_first_node_in_group("Player")
@onready var _room: Area2D = get_parent()

# States
var state: EnemyState

var WANDER: WanderState = WanderState.new(self)
var FOLLOW: FollowState = FollowState.new(self)
var ATTACK: AttackState = AttackState.new(self)

#shock variables
var is_shocked = false
var shock_duration = 3
var speed = 50 

signal following_started

func _ready() -> void:
	max_health = 100
	current_health = 50
	_timer.timeout.connect(self._update_pathfinding)
	_update_pathfinding()
	add_to_group("Enemies")

func _physics_process(delta):
	pass
#	print(global_position.distance_to(_player.global_position))
#	if _agent.is_navigation_finished():
#		await get_tree().create_timer(0.3).timeout
#		return
#
#	var direction = global_position.direction_to(_agent.get_next_path_position())
#
#	var desired_velocity = direction * speed 
#	var steering = (desired_velocity - _velocity) * delta * 4.0
#	_velocity += steering
#
#	set_velocity(_velocity)
#	move_and_slide()

func _process(_delta):
	if state:
		state.update()
	if current_health <= 0:
		queue_free()

func _update_pathfinding() -> void:
	await get_tree().create_timer(0.1).timeout
	var bodies = _room.get_overlapping_bodies()
	for body in bodies:
		if body.is_class("Player"):
			_agent.set_target_position(_player.global_position)

func apply_shock() -> void:
	if not is_shocked:
		is_shocked = true
		speed = 0
		await get_tree().create_timer(shock_duration).timeout
		speed = 50
		is_shocked = false

func change_state(new_state):
	state.exit()
	state = new_state
	new_state.enter()

class EnemyState:
	extends RefCounted
	var enemy: Enemy
	
	@warning_ignore("shadowed_variable")
	func _init(enemy: Enemy):
		self.enemy = enemy
	
	func enter():
		pass
	
	func update():
		pass
	
	func exit():
		pass
	
	@warning_ignore("unused_parameter")
	func try_transition(state: EnemyState):
		pass

class WanderState:
	extends EnemyState
	
	var directions: Array[Vector2] = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1),
		Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
	
	func update():
		enemy.global_position += directions[enemy.pick_random()] * enemy.speed

class FollowState:
	extends EnemyState
	
	func update():
		if enemy._agent.is_navigation_finished():
			await enemy.get_tree().create_timer(0.3).timeout
			return
		
		var direction = enemy.global_position.direction_to(enemy._agent.get_next_path_position())
		
		var desired_velocity = enemy.direction * enemy.speed
		var steering = (enemy.desired_velocity - enemy._velocity) * enemy.delta * 4.0
		enemy._velocity += steering
		
		enemy.set_velocity(enemy._velocity)
		enemy.move_and_slide()

class AttackState:
	extends EnemyState




