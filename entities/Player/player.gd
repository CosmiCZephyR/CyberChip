class_name Player
extends Entity

# Main variables
var direction: Vector2 = Vector2.ZERO
const PLAYER_SIZE: Vector2 = Vector2(11,15)
@export var speed: float = 65
@onready var sec_timer: Timer = $SecTimer
@onready var player_rect: Rect2 = Rect2(global_position - PLAYER_SIZE / 2, PLAYER_SIZE)

# Tilemap
@onready var tilemap: TileMap = get_node("/root/TestScene/TileMap2")

# Animations
@onready var animation_tree: AnimationTree = $AnimationTree

var current_animation = "idle"

# Rooms
var _current_room: Area2D: set = set_current_room
var previous_room: Area2D = _current_room

# Dash
var can_dash: bool = true
var dash_duration: float = 0.2
var dash_cooldown: float = 2.0
var dash_speed: int = 5000
@warning_ignore("unused_parameter")
@onready var duration_timer = $DashDuration
@warning_ignore("unused_parameter")
@onready var cooldown_timer = $DashCooldown

# Abilities
@onready var _magnetism: Magnetism = load_ability("magnetism")
@onready var _repairing: Repairing = load_ability("repairing")
@onready var _magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var nearby_component: Area2D
var transistor: Transistor
var is_paused = false

func _ready() -> void:
	Event.transistor_selected.connect(_on_transistor_available)
	InputHandler.magneticShock.connect(_on_magnetic_shock)
	InputHandler.interaction.connect(_on_interaction)
#	InputHandler.magnetism.connect(_on_magnetism)
	InputHandler.repairing.connect(_on_repairing)
	sec_timer.timeout.connect(_second_passed)
	animation_tree.active = true

func _physics_process(_delta) -> void:
	direction = Input.get_vector("left", "right", "up", "down")

func _process(_delta) -> void:
	update_animation_parameters()
	
	if Input.is_action_pressed("magnetism"):
		_magnetism.activate(player_rect, self, _delta)

#func _on_magnetism() -> void:
#	var _delta = get_physics_process_delta_time()
#	_magnetism.activate(player_rect, self, _delta)

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
	self.regen_health()
	self.regen_kosuki()

func set_current_room(_area) -> void:
	_current_room = _area

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
