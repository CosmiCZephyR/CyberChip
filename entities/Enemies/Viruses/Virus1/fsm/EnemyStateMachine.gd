extends Node
class_name EnemyStateMachine

@onready var enemy: Enemy = get_parent()

@onready var wander_state = WanderState.new(enemy, self)
@onready var follow_state = FollowState.new(enemy, self)
@onready var attack_state = AttackState.new(enemy, self)

@onready var state: EnemyState = wander_state

func _ready() -> void:
	await get_parent().ready
	state.enter()

func _process(delta: float) -> void:
	if state:
		state.update(delta)

func change_state(new_state: EnemyState):
	state.exit()
	state = new_state
	new_state.enter()
