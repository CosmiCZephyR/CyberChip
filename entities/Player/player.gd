class_name Player
extends Entity

# Main variables
var speed: float = 65
var direction: Vector2 = Vector2.ZERO
const PLAYER_SIZE: Vector2 = Vector2(11,15)
@onready var sec_timer: Timer = $SecTimer
@onready var player_rect: Rect2 = Rect2(global_position - PLAYER_SIZE / 2, PLAYER_SIZE)

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

# Abilities
@onready var magnetism: Magnetism = load_ability("magnetism")
@onready var repairing: Repairing = load_ability("repairing")
@onready var magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

# Components
var nearby_component: Area2D

var transistor = null

var is_paused = false

func _ready():
	animation_tree.active = true
	Event.transistor_selected.connect(_on_transistor_available)
	sec_timer.timeout.connect(_second_passed)
	add_to_group("Player")

func _physics_process(_delta):
	if Input.is_action_just_pressed("pause") and not is_paused:
		get_tree().paused = true
		is_paused = true
	elif Input.is_action_just_pressed("pause") and is_paused:
		get_tree().paused = false
		is_paused = false
	
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
