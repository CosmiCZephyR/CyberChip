class_name Resistor
extends Area2D

@onready var item = load("res://InventorySystem/Resouces/Resources/Resistor.tres")
var tile_items_container

@onready var _input_handler: Control = $DragNDropInputHolder

var _flag: bool = false

var _speed_modifier: float = 0.666
var _normal_speed: float = 65

var _cosuki_modifier: float = 0.75

func _ready() -> void:
	_input_handler.item_dragged.connect(_on_item_dragged)
	
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)

func _physics_process(_delta) -> void:
	for _body in get_overlapping_bodies():
		if _body.is_in_group("Player") and not _flag:
			_body.current_kosuki *= _cosuki_modifier
			_flag = true

func _body_entered(_body) -> void:
	if _body.is_in_group("Player"):
		_body.speed *= _speed_modifier

func _body_exited(_body) -> void:
	if _body.is_in_group("Player"):
		_body.speed = _normal_speed

func _on_item_dragged() -> void:
	queue_free()
