class_name WalkState
extends CharacterState

var connected = false

func enter():
	if player.can_dash:
		connected = true
		InputHandler.dash.connect(try_transition.bind(state_machine.DASH))

func exit():
	if connected:
		connected = false
		InputHandler.dash.disconnect(try_transition.bind(state_machine.DASH))

func update():
	player.direction = Input.get_vector("left", "right", "up", "down")
	player.movement = player.direction * player.speed
	player.set_velocity(player.movement)
	player.move_and_slide()
	
	if not Input.is_anything_pressed():
		try_transition(state_machine.IDLE)

func try_transition(state: CharacterState):
	state_machine.change_state_to(state)
