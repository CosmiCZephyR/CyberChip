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

# ANIMATIONs
@onready var animation_tree: AnimationTree = $AnimationTree

# Rooms
var current_room: Area2D
var previous_room: Area2D = current_room

# Dash
var can_dash: bool = true
var dash_speed: int = 5000
var dash_duration: float = 0.2
var dash_cooldown: float = 2.0
@onready var duration_timer = $DashDuration
@onready var cooldown_timer = $DashCooldown

# State machine
enum States {IDLE, WALK, DASH, SPRINT, ATTACK}

var current_state = States.IDLE: set = change_state

# Abilities
@onready var magnetism: Magnetism = load_ability("magnetism")
@onready var repairing: Repairing = load_ability("repairing")
@onready var magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var nearby_component: Area2D

var transistor = null

# Double click

var max_double_click_time: float = 250
var last_key_press_time: float = 0.0
var key_code: int = 0

func _ready():
	animation_tree.active = true
	Event.transistor_selected.connect(self._on_transistor_available)
	sec_timer.timeout.connect(self._second_passed)
	add_to_group("Player")

func _physics_process(_delta):
	if Input.is_action_pressed("Magnetism"):
		magnetism.activate(player_rect, _delta, self)
	if Input.is_action_just_pressed("Repairing"):
		repairing.activate_repairing(tilemap, self)
	if Input.is_action_pressed("MagneticShock"):
		magnetic_shock.activate_magnetic_shock(owner)
	if Input.is_action_just_pressed("toggle") and transistor != null:
		transistor.toggle()
	
	direction = Input.get_vector("left", "right", "up", "down")
	
	movement = direction * speed
	movement = movement.normalized() * speed
	set_velocity(movement)
	move_and_slide()
	

func _process(_delta):
	update_animation_parameters()

func is_double_click(e):
	var current_time := Time.get_ticks_msec()
	return current_time - last_key_press_time < max_double_click_time and e.get_keycode() == key_code and can_dash and not e.is_echo()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		var current_time := Time.get_ticks_msec()
		direction = Input.get_vector("left", "right", "up", "down")
		if is_double_click(event):
			dash(direction)
			change_state(States.DASH)
		last_key_press_time = current_time
		key_code = event.get_keycode() 

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
	var current_state = "idle"
	
	if movement != Vector2.ZERO:
		current_state = "walk"
		animation_tree["parameters/walk/blend_position"] = movement.normalized()
	elif Input.is_action_pressed("attack"):
		current_state = "attack"
		animation_tree["parameters/attack/blend_position"] = position.direction_to(get_global_mouse_position()).normalized()
	
	animation_tree["parameters/conditions/idle"] = current_state == "idle"
	animation_tree["parameters/conditions/walk"] = current_state == "walk"
	animation_tree["parameters/conditions/attack"] = current_state == "attack"

func change_state(new_state):
	current_state = new_state
	return new_state

func idle_state():
	current_state = States.IDLE
	if Input.is_action_just_pressed("attack"):
		change_state(States.ATTACK)
	elif Input.is_anything_pressed():
		change_state(States.WALK)

func walk_state():
	current_state = States.WALK
	
	if movement == Vector2.ZERO:
		change_state(States.IDLE)
	if is_double_click(Input):
		change_state(States.DASH)

func attack_state():
	if Input.is_action_just_pressed("attack"):
		change_state(States.ATTACK)

