class_name PlayerStateMachine
extends Node2D

@onready var player = get_parent()

@onready var IDLE : IdleState     = IdleState.new(player, self)
@onready var WALK : WalkState     = WalkState.new(player, self)
@onready var DASH : DashState     = DashState.new(player, self)
@onready var SPRINT : SprintState = SprintState.new(player, self)

@onready var state: CharacterState = IDLE

func _ready():
	print(player)
	await get_parent().ready
	state.enter()

func _process(_delta):
	if state:
		state.update()

func change_state_to(new_state):
	state.exit()
	state = new_state
	new_state.enter()
