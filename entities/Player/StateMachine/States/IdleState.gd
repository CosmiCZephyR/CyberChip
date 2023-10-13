class_name IdleState 
extends CharacterState

func enter():
	InputHandler.movement.connect(try_transition.bind(state_machine.WALK))
	InputHandler.dash.connect(try_transition.bind(state_machine.DASH))

func exit():
	InputHandler.movement.disconnect(try_transition)
	InputHandler.dash.disconnect(try_transition)

func try_transition(state: CharacterState):
	state_machine.change_state_to(state)
