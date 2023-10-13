class_name CharacterState
extends RefCounted

var player: Player
var state_machine: PlayerStateMachine

@warning_ignore("shadowed_variable")
func _init(player: Player, state_machine: PlayerStateMachine):
	self.player = player
	self.state_machine = state_machine

func enter():
	pass

func exit():
	pass

func update():
	pass

@warning_ignore("unused_parameter")
func try_transition(state: CharacterState):
	pass
