class_name SprintState
extends CharacterState

func enter():
	player.speed = 100

func update():
	player.movement = player.speed * player.direction
	player.set_velocity(player.movement)
	player.move_and_slide()
	
	if not Input.is_action_pressed("movement"):
		try_transition(state_machine.IDLE)

func exit():
	player.speed = 65

func try_transition(state: CharacterState):
	state_machine.change_state_to(state)
