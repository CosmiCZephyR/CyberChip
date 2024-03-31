extends EnemyState
class_name WanderState

const MIN_TIME: float = 0.5
const MAX_TIME: float = 1.5

var directions: Dictionary = {
	Vector2(0, 0): 50,
	Vector2(1, 0): 12.5,
	Vector2(-1, 0): 12.5,
	Vector2(0, 1): 12.5,
	Vector2(0, -1): 12.5,
}

var current_direction: Vector2

var wander_time: float

func enter():
	print_debug("Wander")
	enemy.get_node("RandomTimer").timeout.connect(random_timeout)
	enemy.following_started.connect(try_transition.bind(state_machine.follow_state))

func random_timeout():
	await enemy.get_tree().create_timer(0.1).timeout
	current_direction = pick_direction()
	wander_time = randf_range(MIN_TIME, MAX_TIME)
	enemy.get_node("RandomTimer").start(wander_time)

func pick_direction():
	var total = 0
	
	for weight in directions.values():
		total += weight
	
	var random = randi_range(0, total)
	var upto = 0
	
	for item in directions.keys():
		if upto + directions[item] >= random:
			return item
		upto += directions[item]

func update(_delta):
	enemy.global_position.clamp(enemy.first_corner, enemy.second_corner)
	
	if enemy._velocity.x < 0:
		enemy.get_node("VirusHit").flip_h = true
		enemy.get_node("AttackHitBox").scale.x = -1
	elif enemy._velocity.x > 0:
		enemy.get_node("VirusHit").flip_h = false
		enemy.get_node("AttackHitBox").scale.x = 1
	
	enemy._velocity = current_direction * (enemy.speed * 0.5)
	enemy.set_velocity(enemy._velocity)
	enemy.move_and_slide()

func exit():
	enemy.get_node("RandomTimer").timeout.disconnect(random_timeout)
	enemy.following_started.disconnect(try_transition.bind(state_machine.follow_state))

func try_transition(state: EnemyState):
	state_machine.change_state(state)
