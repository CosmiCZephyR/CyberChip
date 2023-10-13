class_name DashState
extends CharacterState 

func enter():
	player.direction = Input.get_vector("left", "right", "up", "down")
	dash(player.direction)
	InputHandler.movement.connect(try_transition.bind(state_machine.SPRINT))

func exit():
	InputHandler.movement.disconnect(try_transition.bind(state_machine.SPRINT))

func update():
	if not Input.is_anything_pressed():
		try_transition(state_machine.IDLE)

func dash(input_vector):
	player.duration_timer.start(player.dash_duration)
	player.movement = input_vector * player.dash_speed
	player.set_velocity(player.movement)
	player.move_and_slide()
	player.can_dash = false
	player.cooldown_timer.start(player.dash_cooldown)

func try_transition(state: CharacterState):
	state_machine.change_state_to(state)
