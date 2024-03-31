extends EnemyState
class_name AttackState

func enter():
	print_debug("Attack")
	enemy.attack_released.connect(try_transition.bind(state_machine.follow_state))

func update(_delta):
	await enemy.get_tree().create_timer(0.5).timeout
	enemy.emit_signal("attack_released")

func exit():
	enemy.attack_released.disconnect(try_transition.bind(state_machine.follow_state))

func try_transition(state: EnemyState):
	state_machine.change_state(state)
