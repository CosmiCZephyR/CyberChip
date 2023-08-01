extends Area2D

class_name EnergySource

var wire_layer = 1
var broken_wires_layer = 2

@onready var _tilemap: TileMap = get_parent()

var glowing_tiles: Dictionary = {}

func _process(delta):
	fool_fill(_tilemap.local_to_map(global_position))

# вызываем на заранее свободной клетке
func fool_fill(pos: Vector2i):
	await get_tree().create_timer(0.5).timeout
	var neighboring_tiles = get_neighbors_pos(pos)
	
	for neighbor_tile in neighboring_tiles:
		_tilemap.set_cell(1, neighbor_tile, -1)
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

