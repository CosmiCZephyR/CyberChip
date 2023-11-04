class_name Door
extends StaticBody2D

@onready var _room: Area2D = get_parent()
@onready var _animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var _wires_manager = WiresManager

@export var transistor: Transistor

var wires_connected: bool 
var open: bool = false
var transistor_on: bool = false

func _ready():
	Event.transistor_activated.connect(self.transistor_door_open)

func _process(_delta):
	wires_connected = await _is_wire_connected()
	if wires_connected and not open and (not _room.has_node("Transistor") or transistor_on):
		open_door(self)

func _is_wire_connected():
	await get_tree().create_timer(0.1).timeout
	return _wires_manager.check_wires_connection(_room)

func open_door(_door) -> void:
	if not (open and _animation.is_playing()):
		_animation.play("Open")
		open = true

func transistor_door_open(_transistor) -> void:
	transistor = _transistor
	transistor_on = transistor.get_state()
	if transistor.get_state() and not open:
		_animation.play("Open")
		open = true
	elif not transistor.get_state() and open:
		_animation.play_backwards("Open")
		open = false
