extends Entity

class_name player

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
# NOTE: ОЧЕНЬ напрашивается машина состояний
# получится избавиться от лишних переменных и сигналов в классе
var can_dash: bool = true
var dash_speed: int = 5000
var dash_duration: float = 0.2
var dash_cooldown: float = 2.0

var moving: bool = false
var attacking: bool = false

# Abilities
@onready var magnetism: Magnetism = load_ability("magnetism")
@onready var repairing: Repairing = load_ability("repairing")
@onready var magnetic_shock: Magnetic_shock = load_ability("magnetic_shock")

func _ready():
	animation_tree.active = true
	add_to_group("Player")

func _physics_process(_delta):
	# TODO: можно будет потом заменить на таймер ноду
	counter += 1
	if counter % 60 == 0:
		self.regen_health()
		self.regen_kosuki()
	
	direction = Input.get_vector("left", "right", "up", "down")
	
	var input_vector = get_input_vector()
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dash(input_vector)
	elif $DashDuration.time_left == 0:
		movement = input_vector * speed
	
	Movement(_delta)

func _process(_delta):
	update_animation_parameters()
	magnetism.activate(player_rect, _delta, self)
	repairing.activate_repairing(tilemap, self)
	magnetic_shock.activate_magnetic_shock(owner)
	
	# TODO: перенести в скрипт двери и комнаты
	if current_room != previous_room:
		door_open = false
		previous_room = current_room
	
	if current_door != null:
		open_door(current_door)

func _on_dash_duration_timeout():
	movement = Vector2.ZERO
	can_dash = false

func _on_dash_cooldown_timeout():
	can_dash = true

@warning_ignore("shadowed_variable")
func check_wires_connection(tilemap: TileMap, area: Area2D):
	var atlas_coords_list: Array = [
		Vector2i(6, 2),
		Vector2i(7, 2),
		Vector2i(7, 3),
		Vector2i(7, 4),
		Vector2i(6, 4),
		Vector2i(5, 4)
	]
	var collision_shape = area.get_node("CollisionShape2D")
	var shape_extents = collision_shape.shape.extents
	var area_rect = Rect2(area.global_position - shape_extents, shape_extents * 2)
	
	# TODO: реклмендую перенести поломанные тайлы проводов в отдельный слой или сделать их тайлами-сцен
	# избавиться от atlas_coords_list
	for cell in tilemap.get_used_cells(1):
		var cell_position = tilemap.map_to_local(cell)
		if not area_rect.has_point(cell_position):
			continue
		var cell_atlas_coords = tilemap.get_cell_atlas_coords(1, cell)
		if cell_atlas_coords in atlas_coords_list:
			return false
	
	return true

func open_door(current_door):
	if not door_open:
		await get_tree().create_timer(0.1).timeout
		var wires_connected = check_wires_connection(tilemap, current_room)
		if wires_connected:
			var door_animation: AnimationPlayer = current_door.get_node("AnimationPlayer")
			door_animation.play("Open")
			door_open = true

func Movement(delta):
	# TODO: проверить, что move_and_slide уже умножает на дельта тайм
	# если так, убрать умножение
	speed += acceleration * delta
	movement = movement.normalized() * speed
	set_velocity(movement)
	move_and_slide()

# this function returns normalized input vector
func get_input_vector():
	var input_vector = Vector2()
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	return input_vector.normalized()

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

# NOTE: в скором времени напрашивается еще одна машина состояний для анимаций
func update_animation_parameters():
	var current_state = "idle"
	
	if movement != Vector2.ZERO:
		current_state = "walk"
		animation_tree["parameters/walk/blend_position"] = movement.normalized()
	elif Input.is_action_pressed("attack"):
		current_state = "attack"
		animation_tree["parameters/attack/blend_position"] = position.direction_to(get_global_mouse_position()).normalized()
	
	# NOTE: изменения стейта анимации лучше выделить в методы перехода
	animation_tree["parameters/conditions/idle"] = current_state == "idle"
	animation_tree["parameters/conditions/walk"] = current_state == "walk"
	animation_tree["parameters/conditions/attack"] = current_state == "attack"
