extends StaticBody2D

class_name Door

var wires_connected: bool 
var open: bool = false
var transistor_on: bool = false

@export var transistor: Transistor

@onready var _player: Player = get_node("/root/TestScene/Player")
@onready var _animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var _room: Area2D = get_parent()

func _ready():
	Event.transistor_activated.connect(self.transistor_door_open)

func _process(_delta):
	wires_connected = _player.check_wires_connection(_room)
	if wires_connected and (not _room.has_node("Transistor") or transistor_on):
		open_door(self)

func open_door(_door) -> void:
	if not open and not _animation.is_playing():
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
