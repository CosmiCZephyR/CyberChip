class_name Door
extends StaticBody2D

@onready var _room: Area2D = get_parent()
@onready var _animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var _wires_manager = WiresManager

@export var transistor: Transistor
@export var is_open: bool = false

var wires: bool 
var transistor_on: bool = false

func _ready():
	WiresManager.wires_connected.connect(self._on_wires_connected)
	Event.transistor_activated.connect(self._on_transistor_activated)

func _process(delta: float) -> void:
	wires = await _is_wire_connected()

func _is_wire_connected():
	await get_tree().create_timer(0.1).timeout
	return _wires_manager.check_wires_connection(_room)

#func open() -> void:
	#if not _animation.is_playing() and not is_open and await _is_wire_connected():
		#_animation.play("Open")
		#is_open = true

func absolute_open(_door):
	_door._animation.play("Open")
	_door.is_open = true

func _on_wires_connected(area):
	if not (_animation.is_playing() and is_open):
		_animation.play("Open")
		is_open = true

func _on_transistor_activated(_transistor):
	transistor = _transistor
	transistor_on = transistor.get_state()
	if transistor_on and not is_open:
		_animation.play("Open")
		is_open = true
	elif not transistor_on and is_open:
		_animation.play_backwards("Open")
		is_open = false
