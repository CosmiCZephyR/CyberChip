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

# Sprint

var sprint_speed: float = 100.0

# Dash
var can_dash: bool = true
var dash_speed: int = 5000
var dash_duration: float = 0.2
var dash_cooldown: float = 2.0
@onready var duration_timer = $DashDuration
@onready var cooldown_timer = $DashCooldown

# State machine
var IDLE : IdleState = IdleState.new(self)
var WALK : WalkState = WalkState.new(self)
var DASH : DashState = DashState.new(self)
var SPRINT : SprintState = SprintState.new(self)
var ATTACK : AttackState = AttackState.new(self)

var state: CharacterState = IDLE

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
	state.enter()
	sec_timer.timeout.connect(self._second_passed)
	add_to_group("Player")

func _physics_process(_delta):
	if Input.is_action_pressed("magnetism"):
		magnetism.activate(player_rect, _delta, self)
	if Input.is_action_just_pressed("repairing"):
		repairing.activate_repairing(tilemap, self)
	if Input.is_action_pressed("magneticShock"):
		magnetic_shock.activate_magnetic_shock(self)
	if Input.is_action_just_pressed("interaction") and transistor != null:
		transistor.toggle()
	
	direction = Input.get_vector("left", "right", "up", "down")

func _process(_delta):
	update_animation_parameters()
	if state:
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

class CharacterState:
	
	var player: Player
	
	@warning_ignore("shadowed_variable")
	func _init(player: Player):
		self.player = player
	
	func enter():
		pass
	
	func exit():
		pass
	
	func update():
		pass
	
	@warning_ignore("unused_parameter")
	func try_transition(state: CharacterState):
		pass

class IdleState:
	extends CharacterState
	
	func enter():
		print("Idle")
#		player.current_animation = "idle"
#		player.animation_tree["parameters/conditions/idle"] = player.current_animation == "idle"
		# TODO: тут коннектишь сигналы
		InputHandler.movement.connect(try_transition.bind(player.WALK))
		InputHandler.attack.connect(try_transition.bind(player.ATTACK))
		InputHandler.dash.connect(try_transition.bind(player.DASH))
	
	func exit():
		InputHandler.movement.disconnect(try_transition)
		InputHandler.attack.disconnect(try_transition)
		InputHandler.dash.disconnect(try_transition)
	
	func try_transition(state: CharacterState):
		# TODO: заменить на коннект к сигналу
		player.change_state_to(state)

class WalkState:
	extends CharacterState
	
	var connected = false
	
	func enter():
		print("Walk")
#		player.current_animation = "walk"
#		player.animation_tree["parameters/walk/blend_position"] = player.movement.normalized()
#		player.animation_tree["parameters/conditions/walk"] = player.current_animation == "walk"
		player.speed = 65
		if player.can_dash:
			connected = true
			InputHandler.dash.connect(try_transition.bind(player.DASH))
	
	func exit():
		if connected:
			connected = false
			InputHandler.dash.disconnect(try_transition.bind(player.DASH))
	
	func update():
		player.direction = Input.get_vector("left", "right", "up", "down")
		player.movement = player.direction * player.speed
		player.movement = player.movement.normalized() * player.speed
		player.set_velocity(player.movement)
		player.move_and_slide()
		
		if not Input.is_anything_pressed():
			try_transition(player.IDLE)
	
	func try_transition(state: CharacterState):
		player.change_state_to(state)

class DashState:
	extends CharacterState
	
	func enter():
		print("Dash")
		player.direction = Input.get_vector("left", "right", "up", "down")
		player.dash(player.direction)
		InputHandler.movement.connect(try_transition.bind(player.SPRINT))
	
	func exit():
		InputHandler.movement.disconnect(try_transition.bind(player.SPRINT))
	
	func update():
		if not Input.is_anything_pressed():
			try_transition(player.IDLE)
	
	func try_transition(state: CharacterState):
		player.change_state_to(state)

class SprintState:
	extends CharacterState
	
	func enter():
		print("Sprint")
		player.speed = player.sprint_speed
	
	func update():
		player.direction = Input.get_vector("left", "right", "up", "down")
		player.movement = player.movement.normalized() * player.speed * player.direction
		player.set_velocity(player.movement)
		player.move_and_slide()
		
		if not Input.is_anything_pressed():
			try_transition(player.IDLE)
	
	func try_transition(state: CharacterState):
		player.change_state_to(state)

class AttackState:
	extends CharacterState
	
	func enter():
#		player.current_animation = "attack"
#		player.animation_tree["parameters/attack/blend_position"] = position.direction_to(get_global_mouse_position()).normalized()
		pass
