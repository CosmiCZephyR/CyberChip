class_name Player
extends Entity

# TODAY I INTRODUCE YOU THE MAINEST VALUE IN THIS UNIVERSE!!!!
const LEALEALEADOSSA_AAMKO = "{{{L100, 100}{100, 100} [&] L,10}{10,10} [&] L, 10}L, 10}{10, 10}100, 10"

# Main variables
@export var speed: float = 65
@export var save_resource: PlayerRes

@onready var saver = Saver.new()
@onready var sec_timer: Timer = $SecTimer
@onready var player_rect: Rect2 = Rect2(global_position - PLAYER_SIZE / 2, PLAYER_SIZE)
@onready var hud: CanvasLayer = get_node("CanvasLayer")
@onready var pause_menu: Control = get_node(pause_path)
@onready var state_machine: PlayerStateMachine = get_node("PlayerStateMachine")

const PLAYER_SIZE: Vector2 = Vector2(11,15)
var direction: Vector2 = Vector2.ZERO

# Paths
var pause_path: NodePath = NodePath("CanvasLayer/Control/CenterContainer")

# Tilemap
@onready var tilemap: TileMap = get_node("/root/TestScene/TileMap2")

# Animations
var current_animation = "idle"
@onready var animation_tree: AnimationTree = $AnimationTree

# Rooms
var _current_room: Area2D: set = set_current_room
var previous_room: Area2D = _current_room

# Dash
var can_dash: bool = true
var dash_speed: int = 5000
var dash_cooldown: float = 2.0
var dash_duration: float = 0.2

@warning_ignore("unused_parameter")
@onready var duration_timer = $DashDuration

@warning_ignore("unused_parameter")
@onready var cooldown_timer = $DashCooldown

# Abilities
@onready var _magnetism: Magnetism = load_ability("magnetism")
@onready var _repairing: Repairing = load_ability("repairing")
@onready var _magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var is_paused: bool = false
var transistor: Transistor
var nearby_component: Area2D

# Misc
var paused: bool = false

func _ready() -> void:
	Event.transistor_selected.connect(_on_transistor_available)
	InputHandler.magneticShock.connect(_on_magnetic_shock)
	InputHandler.interaction.connect(_on_interaction)
	InputHandler.repairing.connect(_on_repairing)
	InputHandler.pause.connect(_on_pause)
	sec_timer.timeout.connect(_second_passed)
	animation_tree.active = true

func _physics_process(_delta) -> void:
	direction = Input.get_vector("left", "right", "up", "down")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("save"):
		saver.save_game_data(get_parent().save_resource)
	
	pause_menu.visible = paused
	update_animation_parameters()
	
	if Input.is_action_pressed("magnetism"):
		_magnetism.activate(player_rect, self, _delta)

#region Accept Sinals
func _on_pause():
	if not paused:
		paused = true
	else:
		paused = false

func _on_repairing() -> void:
	_repairing.activate_repairing(tilemap, self)

func _on_magnetic_shock() -> void:
	_magnetic_shock.activate_magnetic_shock(self)

func _on_interaction() -> void:
	if transistor != null:
		transistor.toggle()

func _on_dash_duration_timeout() -> void:
	movement = Vector2.ZERO
	can_dash = false

func _on_dash_cooldown_timeout() -> void:
	can_dash = true

func _on_transistor_available(_transistor) -> void:
	transistor = _transistor

func _second_passed() -> void:
	regen_health()
	regen_kosuki()
#endregion

func set_current_room(_area) -> void:
	_current_room = _area
	save_resource.current_room = _current_room

## Upadate aniamation parameters
func update_animation_parameters() -> void:
	current_animation = "idle"
	
	if movement != Vector2.ZERO:
		current_animation = "walk"
		animation_tree["parameters/walk/blend_position"] = movement.normalized()
	elif Input.is_action_pressed("attack"):
		current_animation = "attack"
		animation_tree["parameters/attack/blend_position"] = position.direction_to(get_global_mouse_position()).normalized()
	
	animation_tree["parameters/conditions/idle"] = current_animation == "idle"
	animation_tree["parameters/conditions/walk"] = current_animation == "walk"
	animation_tree["parameters/conditions/attack"] = current_animation == "attack"
