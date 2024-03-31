class_name EnergySource
extends Area2D

var wire_layer: int = 1
var broken_wires_layer: int = 2
var glowing_wires_layer: int = 3

@onready var _tilemap: TileMap = get_parent()
@onready var _manager = WiresManager
@onready var _update_timer: Timer = $Timer

func _ready():
	_update_timer.timeout.connect(_timer_timeout)

func _timer_timeout():
	if _manager.tilemap:
		_manager.fool_fill(_tilemap.local_to_map(global_position))
