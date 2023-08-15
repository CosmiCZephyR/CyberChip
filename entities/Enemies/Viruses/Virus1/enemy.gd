extends Entity

class_name Enemy

var enemy_virus: Entity = Entity.new()

var _velocity: Vector2 = Vector2.ZERO

@onready var _timer: Timer = $Timer
@onready var _agent: NavigationAgent2D = $NavigationAgent2D
@onready var _player: Player = get_tree().get_first_node_in_group("Player")
@onready var _room: Area2D = get_parent()

# States
var WANDER: WanderState = WanderState.new(self)
var FOLLOW: FollowState = FollowState.new(self)
var ATTACK: AttackState = AttackState.new(self)

var state: EnemyState = WANDER

#shock variables
var is_shocked = false
var shock_duration = 3
var speed = 50 

signal following_started
signal following_finished
signal zone_exited
signal attack_released

func _ready() -> void:
	max_health = 100
	current_health = 50
	_timer.timeout.connect(self._update_pathfinding)
	state.enter()
#	_update_pathfinding()
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
		state.update(_delta)
	
	if current_health <= 0:
		queue_free()

func _update_pathfinding() -> void:
	await get_tree().create_timer(0.1).timeout
	var bodies = _room.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			_agent.set_target_position(_player.global_position)
			emit_signal("following_started")

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
	
	func update(delta):
		pass
	
	func exit():
		pass
	
	@warning_ignore("unused_parameter")
	func try_transition(state: EnemyState):
		pass

class WanderState:
	extends EnemyState
	
	var directions: Array[Vector2] = [
		Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1),
#		Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)
	]
	
	var current_direction: Vector2
	
	const MIN_TIME: float = 0.5
	const MAX_TIME: float = 1.5
	
	var wander_time: float
	
	func enter():
		print_debug("Wander")
		enemy.get_node("RandomTimer").timeout.connect(random_timeout)
		enemy.following_started.connect(try_transition.bind(enemy.FOLLOW))
	
	func random_timeout():
		current_direction = directions.pick_random()
		wander_time = randf_range(MIN_TIME, MAX_TIME)
		enemy.get_node("RandomTimer").start(wander_time)
	
	func update(delta):
		if current_direction.x < 0:
			enemy.get_node("VirusHit").flip_h = true
		else: 
			enemy.get_node("VirusHit").flip_h = false
		
		enemy.global_position.clamp(Vector2(-85.5, 54.5), Vector2(89.5, -40.5))
		
		enemy._velocity = current_direction * (enemy.speed * 0.66)
		enemy.set_velocity(enemy._velocity)
		enemy.move_and_slide()
	
	func exit():
		enemy.get_node("RandomTimer").timeout.disconnect(random_timeout)
		enemy.following_started.disconnect(try_transition.bind(enemy.FOLLOW))
	
	func try_transition(state: EnemyState):
		enemy.change_state(state)

class FollowState:
	extends EnemyState
	
	func enter():
		print_debug("Follow")
		enemy.following_finished.connect(try_transition.bind(enemy.ATTACK))
		enemy.zone_exited.connect(try_transition.bind(enemy.WANDER))
		enemy._room.body_exited.connect(body_excited)
	
	func body_excited(_body):
		enemy.emit_signal("zone_exited")
	
	func update(delta):
		if enemy._agent.is_navigation_finished():
			enemy.emit_signal("following_finished")
			try_transition(enemy.WANDER)
		
		var direction = enemy.global_position.direction_to(enemy._agent.get_next_path_position())
		
		if direction.x < 0:
			enemy.get_node("VirusHit").flip_h = true
		else: 
			enemy.get_node("VirusHit").flip_h = false
		
		var desired_velocity = direction * enemy.speed
		var steering = (desired_velocity - enemy._velocity) * delta * 4.0
		enemy._velocity += steering
		
		enemy.set_velocity(enemy._velocity)
		enemy.move_and_slide()
		
		if enemy._agent.distance_to_target() <= 20:
			try_transition(enemy.ATTACK)
	
	func exit():
		enemy.following_finished.disconnect(try_transition.bind(enemy.ATTACK))
		enemy.zone_exited.disconnect(try_transition.bind(enemy.WANDER))
		enemy._room.body_exited.disconnect(body_excited)
	
	func try_transition(state: EnemyState):
		enemy.change_state(state)

class AttackState:
	extends EnemyState
	
	func enter():
		print_debug("Attack")
		enemy.attack_released.connect(try_transition.bind(enemy.WANDER))
	
	func update(delta):
		await enemy.get_tree().create_timer(0.5).timeout
		enemy.emit_signal("attack_released")
	
	func exit():
		enemy.attack_released.disconnect(try_transition.bind(enemy.WANDER))
	
	func try_transition(state: EnemyState):
		enemy.change_state(state)
