extends Area2D

class_name EnergySource

var wire_layer: int = 1
var broken_wires_layer: int = 2
var glowing_wires_layer: int = 3

@onready var _tilemap: TileMap = get_parent()
@onready var _update_timer: Timer = $Timer

var _material = preload("res://resources/tile_shader.tres")

var glowing_tiles: Dictionary

func _ready():
	_update_timer.timeout.connect(self._timer_timeout)

func _timer_timeout():
	glowing_tiles.clear()
	fool_fill(_tilemap.local_to_map(global_position))

func fool_fill(pos: Vector2i):
	await get_tree().create_timer(0.5).timeout
	var neighboring_tiles = get_neighbors_pos(pos)
	
	for neighbor_tile in neighboring_tiles:
		if neighbor_tile in glowing_tiles:
			continue
		
		var source_id = _tilemap.get_cell_source_id(wire_layer, neighbor_tile)
		var atlas_coords = _tilemap.get_cell_atlas_coords(wire_layer, neighbor_tile)
		
		_tilemap.set_cell(glowing_wires_layer, neighbor_tile, source_id, atlas_coords)
		
#		var _tiledata = _tilemap.get_cell_tile_data(glowing_wires_layer, neighbor_tile)
#
#		if _tiledata:
#			_tiledata.material = _material
		
		glowing_tiles[neighbor_tile] = true
		fool_fill(neighbor_tile)

func get_neighbors_pos(tile_pos: Vector2i) -> Array[Vector2i]:
	var neighbors_pos: Array[Vector2i]
	var neighbor_tile_pos: Vector2i
	
	var neighbors: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	
	for neighbor in neighbors:
		if _tilemap.get_cell_source_id(1, tile_pos + neighbor) != -1:
			neighbor_tile_pos = tile_pos + neighbor
			neighbors_pos.append(neighbor_tile_pos)
	
	return neighbors_pos

