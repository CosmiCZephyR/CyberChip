extends Area2D

class_name EnergyReceiver

var door: Door

@onready var _tilemap: TileMap = get_parent()
@onready var _source: EnergySource

var _material = preload("res://Shaders/tile_shader.tres")

signal open_door

func _ready():
	await get_tree().create_timer(0.2).timeout
	_source = _tilemap.get_node("EnergySource")
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is Door:
			door = body

func _physics_process(_delta):
	var pos = _tilemap.local_to_map(global_position)
	var neighbor_tile = _tilemap.get_neighbor_cell(pos, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	
	var _tiledata: TileData = _tilemap.get_cell_tile_data(3, neighbor_tile)
	
	if _tiledata and _tiledata.material == _material:
		door.open_door(door)
		$Sprite2D.material = _material
