extends Entity

class_name Player

# Main variables
var player_size: Vector2 = Vector2(11,15)
var speed: float = 65
var direction: Vector2 = Vector2.ZERO
@onready var player_rect: Rect2 = Rect2(global_position - player_size / 2, player_size)
@onready var sec_timer: Timer = $SecTimer

# Tilemap
@onready var tilemap: TileMap = get_node("/root/TestScene/TileMap2")

# Animations
@onready var animation_tree: AnimationTree = $AnimationTree

var current_animation = "idle"

# Rooms
var current_room: Area2D: set = get_current_room
var previous_room: Area2D = current_room

# Dash
var can_dash: bool = true
var dash_speed: int = 5000
var dash_duration: float = 0.2
var dash_cooldown: float = 2.0
@onready var duration_timer = $DashDuration
@onready var cooldown_timer = $DashCooldown

# State machine
enum States {ATTACK}

@onready var IDLE = IdleState.new()
@onready var WALK = WalkState.new()
@onready var DASH = DashState.new()
@onready var SPRINT = SprintState.new()
@onready var ATTACK = null

var state = IDLE

# Abilities
@onready var magnetism: Magnetism = load_ability("magnetism")
@onready var repairing: Repairing = load_ability("repairing")
@onready var magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var nearby_component: Area2D

var transistor = null

func _ready():
	animation_tree.active = true
	Event.transistor_selected.connect(self._on_transistor_available)
#	InputHandler.dash.connect(InputHandler.dash)
	sec_timer.timeout.connect(self._second_passed)
	add_to_group("Player")

func _physics_process(_delta):
	if Input.is_action_pressed("Magnetism"):
		magnetism.activate(player_rect, _delta, self)
	if Input.is_action_just_pressed("Repairing"):
		repairing.activate_repairing(tilemap, self)
	if Input.is_action_pressed("MagneticShock"):
		magnetic_shock.activate_magnetic_shock(owner)
	if Input.is_action_just_pressed("interaction") and transistor != null:
		transistor.toggle()
	
	direction = Input.get_vector("left", "right", "up", "down")

func _process(_delta):
	update_animation_parameters()
	state.update()

func _on_dash_duration_timeout():
	movement = Vector2.ZERO
	can_dash = false

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_transistor_available(_transistor):
	transistor = _transistor

func _second_passed():
	self.regen_health()
	self.regen_kosuki()

#func dash_pressed():
#	if can_dash:
#		direction = Input.get_vector("left", "right", "up", "down")
#		dash(direction)

func check_wires_connection(area: Area2D):
	var collision_shape = area.get_node("CollisionShape2D")
	var shape_extents = collision_shape.shape.extents
	var area_rect = Rect2(area.global_position - shape_extents, shape_extents * 2)
	
	var broken_wires_layer = 2
	
	for cell in tilemap.get_used_cells(broken_wires_layer):
		var cell_position = tilemap.map_to_local(cell)
		if not area_rect.has_point(cell_position):
			continue
		
		return false
	
	return true

func get_current_room(area):
	current_room = area

func dash(input_vector):
	duration_timer.start(dash_duration)
	movement = input_vector * dash_speed
	set_velocity(movement)
	move_and_slide()
	can_dash = false
	cooldown_timer.start(dash_cooldown)

func update_animation_parameters():
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

func change_state_to(new_state):
	state.exit()
	state = new_state
	new_state.enter()
	print_debug("change_state_to called with new_state:", new_state)

class CharacterState:
	extends Player
	
	func enter():
		pass
	
	func update():
		pass
	
	func try_transition():
		pass

class IdleState:
	extends CharacterState
	
	func enter():
		current_animation = "idle"
		animation_tree["parameters/conditions/idle"] = current_animation == "idle"
		# TODO: тут коннектишь сигналы
	
	func try_transition():
		# TODO: заменить на коннект к сигналу
		if Input.is_action_pressed("Movement"):
			change_state_to(WALK)
		if Input.is_action_just_pressed("attack"):
			change_state_to(state)
		if InputHandler.is_double_click(InputEventKey) and can_dash:
			change_state_to(DASH)
		print("try_transition called for state:", self)

class WalkState:
	extends CharacterState
	
	func enter():
		current_animation = "walk"
		animation_tree["parameters/walk/blend_position"] = movement.normalized()
		animation_tree["parameters/conditions/walk"] = current_animation == "walk"
	
	func update():
		direction = Input.get_vector("left", "right", "up", "down")
		movement = movement.normalized() * direction * (speed ** 2)
		set_velocity(movement)
		move_and_slide()
		print("update called for state:", self)
	
	func try_transition():
		if InputHandler.is_double_click(InputEventKey) and can_dash:
			change_state_to(DASH)

class DashState:
	extends CharacterState
	
	func enter():
		dash(direction)
	
	func try_transition():
		if Input.is_action_pressed("Movement"):
			change_state_to(SPRINT)
		if not Input.is_anything_pressed():
			change_state_to(IDLE)
		print("try_transition called for state:", self)

class SprintState:
	extends CharacterState
	
	func enter():
		movement *= speed
	
	func try_transition():
		if not Input.is_anything_pressed():
			change_state_to(IDLE)
		print("try_transition called for state:", self)

class AttackState:
	extends CharacterState
	
	func enter():
		current_animation = "attack"
		animation_tree["parameters/attack/blend_position"] = position.direction_to(get_global_mouse_position()).normalized()
