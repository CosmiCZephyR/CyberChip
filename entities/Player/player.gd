extends Entity

class_name Player

# Main variables
var player_size: Vector2 = Vector2(11,15)
var counter: int = 0
var speed: int = 100
var acceleration: float = 1.2
var direction: Vector2 =  Vector2.ZERO
@onready var player_rect: Rect2 = Rect2(global_position - player_size / 2, player_size)

# Door
var door_open = false
var current_door

# Tilemap
@export var path_to_tilemap = NodePath()
@onready var tilemap: TileMap = get_node(path_to_tilemap)

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

# ¿States?
# NOTE: потом, когда количество состояний увеличится сделать енум
var moving: bool = false
var attacking: bool = false

# Abilities
@onready var magnetism: Magnetism = load_ability("magnetism")
@onready var repairing: Repairing = load_ability("repairing")
@onready var magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var nearby_component: Area2D

var transistor = null

func _ready():
	animation_tree.active = true
	Event.transistor_activated.connect(self._on_transistor_available)
	add_to_group("Player")

func _physics_process(_delta):
	counter += 1
	if counter % 60 == 0:
		self.regen_health()
		self.regen_kosuki()
	
	if Input.is_action_pressed("Magnetism"):
		magnetism.activate(player_rect, _delta, self)
	if Input.is_action_just_pressed("Repairing"):
		repairing.activate_repairing(tilemap, self)
	if Input.is_action_pressed("MagneticShock"):
		magnetic_shock.activate_magnetic_shock(owner)
	
	if Input.is_action_just_pressed("toggle") and transistor != null:
		transistor.toggle()
	
	direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dash(direction)
	elif $DashDuration.time_left == 0:
		movement = direction * speed
	
	Movement(_delta)

func _process(_delta):
	update_animation_parameters()

func _on_dash_duration_timeout():
	movement = Vector2.ZERO
	can_dash = false

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_transistor_available(_transistor):
	transistor = _transistor

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

func Movement(delta):
	speed += acceleration * delta
	movement = movement.normalized() * speed
	set_velocity(movement)
	move_and_slide()

func get_current_room(area, door):
	current_door = door
	current_room = area

func dash(input_vector):
	$DashDuration.start(dash_duration)
	movement = input_vector * dash_speed
	set_velocity(movement)
	move_and_slide()
	can_dash = false
	$DashCooldown.start(dash_cooldown)

func Attack():
	await get_tree().create_timer(0.35).timeout
	attacking = false

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
