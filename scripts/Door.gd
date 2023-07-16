extends StaticBody2D

class_name Door

var wires_connected: bool 
var open: bool = false
var transistor: Transistor
var transistor_on: bool = false

@onready var _player: Player = get_node("/root/TestScene/Player")
@onready var _animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var _room: Area2D = get_parent()

func _ready():
	Event.transistor_activated.connect(self.transistor_door_open)

func _process(delta):
	wires_connected = _player.check_wires_connection(_room)
	transistor_on = transistor.get_state()
	if _room.has_node("Transistor"):
		if wires_connected and transistor_on:
			open_door(self)
	else:
		if wires_connected:
			open_door(self)

func open_door(door):
	if not open:
		await get_tree().create_timer(0.1).timeout
		if not _animation.is_playing():
			_animation.play("Open")
			open = true

func transistor_door_open(_transistor):
	transistor = _transistor
	transistor_on = transistor.get_state()
	print(transistor_on)
	if transistor.get_state() and not open:
		_animation.play("Open")
		open = true
