extends RefCounted
class_name EnemyState

var enemy: Enemy
var state_machine: EnemyStateMachine

func _init(enmy: Enemy, stat_machine: EnemyStateMachine):
	enemy = enmy
	state_machine = stat_machine

func enter():
	pass

func update(_delta):
	pass

func exit():
	pass

func try_transition(_state: EnemyState):
	pass
