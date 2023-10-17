extends Node

class_name WiresManange

const WIRE_LAYER: int = 1
const BROKEN_WIRES_LAYER: int = 2
const GLOWING_WIRES_LAYER: int = 3

const ALT_TILE_ID = 1

@onready var tilemap: TileMap = get_tree().current_scene.get_node("TileMap2")
@onready var tiledata: TileData

var _material: ShaderMaterial = preload("res://resources/tile_shader.tres")

var is_running: bool = false

var neighbors: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0)]
var neighboring_tiles: Array[Vector2i]
var neighbors_pos: Array[Vector2i]

var glowing_tiles: Dictionary
var neighbor_tile_pos: Vector2i
var atlas_coords: Vector2i
var source_id: int

var tiles_pos: Dictionary

signal tile_filled

#func start():
#	is_running = true
#
#func stop():
#	is_running = false

func fool_fill(pos: Vector2i):
	glowing_tiles.clear()
	fill_tile(pos)

func fill_tile(pos: Vector2i):
	await get_tree().create_timer(0.5).timeout
	neighboring_tiles = get_neighbors_pos(pos)
	
	for neighbor_tile in neighboring_tiles:
		if neighbor_tile in glowing_tiles:
			continue
		
		source_id = tilemap.get_cell_source_id(WIRE_LAYER, neighbor_tile)
		atlas_coords = tilemap.get_cell_atlas_coords(WIRE_LAYER, neighbor_tile)
		
		tilemap.set_cell(GLOWING_WIRES_LAYER, neighbor_tile, source_id, atlas_coords, ALT_TILE_ID)
		
		glowing_tiles[neighbor_tile] = true
		fill_tile(neighbor_tile)

func get_neighbors_pos(tile_pos: Vector2i) -> Array[Vector2i]:
	neighbors_pos.clear()
	
	for neighbor in neighbors:
		if tilemap.get_cell_source_id(WIRE_LAYER, tile_pos + neighbor) != -1:
			neighbor_tile_pos = tile_pos + neighbor
			neighbors_pos.append(neighbor_tile_pos)
	
	return neighbors_pos

func check_wires_connection(area: Area2D):
	var collision_shape = area.get_node("CollisionShape2D")
	var shape_extents = collision_shape.shape.extents
	var area_rect = Rect2(area.global_position - shape_extents, shape_extents * 2)
	
	for cell in tilemap.get_used_cells(BROKEN_WIRES_LAYER):
		var cell_position = tilemap.map_to_local(cell)
		if not area_rect.has_point(cell_position):
			continue
		
		return false
	
	return true
