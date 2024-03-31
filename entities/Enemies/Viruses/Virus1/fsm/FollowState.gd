extends EnemyState
class_name FollowState

func enter():
	print_debug("Follow")
	enemy.following_finished.connect(try_transition.bind(state_machine.attack_state))
	enemy.zone_exited.connect(try_transition.bind(state_machine.wander_state))
	enemy._room.body_exited.connect(body_excited)

func body_excited(_body):
	enemy.emit_signal("zone_exited")

func update(delta):
	if enemy._agent.is_navigation_finished():
		enemy.emit_signal("following_finished")
		try_transition(state_machine.wander_state)
	
	var direction = enemy.global_position.direction_to(enemy._agent.get_next_path_position())
	
	var desired_velocity = direction * enemy.speed
	var steering = (desired_velocity - enemy._velocity) * delta * 4.0
	enemy._velocity += steering
	
	if enemy._velocity.x < 0:
		enemy.get_node("VirusHit").flip_h = true
		enemy.get_node("AttackHitBox").scale.x = -1
	elif enemy._velocity.x > 0:
		enemy.get_node("VirusHit").flip_h = false
		enemy.get_node("AttackHitBox").scale.x = 1
	
	enemy.set_velocity(enemy._velocity)
	enemy.move_and_slide()
	
	if enemy._agent.distance_to_target() <= 10:
		try_transition(enemy.ATTACK)

func exit():
	enemy.following_finished.disconnect(try_transition.bind(state_machine.attack_state))
	enemy.zone_exited.disconnect(try_transition.bind(state_machine.wander_state))
	enemy._room.body_exited.disconnect(body_excited)

func try_transition(state: EnemyState):
	state_machine.change_state(state)
