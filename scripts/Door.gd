class_name Door
extends StaticBody2D

@onready var _room: Area2D = get_parent()
@onready var _animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var _wires_manager = WiresManager

@export var is_open: bool = false

var wires: bool 
var transistor_on: bool = false

func _ready():
	WiresManager.devices[_room.get_parent().get_node("TileMap2").local_to_map(global_position)] = self

func _process(delta: float) -> void:
	wires = await _is_wire_connected()

func _is_wire_connected():
	await get_tree().create_timer(0.1).timeout
	return _wires_manager.area_has_broken_wires(_room)

func activate():
	if not _animation.is_playing() and not is_open:
		_animation.play("Open")
		is_open = true
	#elif not _animation.is_playing() and is_open:
		#_animation.play_backwards("Open")
		#is_open = false

func absolute_open(_door):
	_door._animation.play("Open")
	_door.is_open = true
