extends Node

class_name WiresManange

## Global wires manager

signal wires_connected(area)
signal tile_filled

@onready var tilemap: TileMap
@onready var tiledata: TileData

enum Layers {
	WIRE_LAYER,
	BROKEN_WIRES_LAYER,
	GLOWING_WIRES_LAYER
}

const ALT_TILE_ID = 1

var is_running: bool = false

var neighboring_tiles: Array[Vector2i]
var neighbors_pos: Array[Vector2i]

static var glowing_tiles: Dictionary
var neighbor_tile_pos: Vector2i
var atlas_coords: Vector2i
var source_id: int

var tiles_pos: Dictionary

var devices: Dictionary

func _physics_process(_delta):
	if get_tree().current_scene:
		tilemap = get_tree().current_scene.get_node_or_null("TileMap2")

func fool_fill(pos: Vector2i) -> void:
	if not tilemap:
		return
	
	glowing_tiles.clear()
	fill_tile(pos)

func fill_tile(pos: Vector2i) -> void:
	await get_tree().create_timer(0.5).timeout
	neighboring_tiles = get_neighbors_pos(pos)
	
	for neighbor_tile in neighboring_tiles:
		if neighbor_tile in glowing_tiles:
			continue
		
		source_id = tilemap.get_cell_source_id(Layers.WIRE_LAYER, neighbor_tile)
		atlas_coords = tilemap.get_cell_atlas_coords(Layers.WIRE_LAYER, neighbor_tile)
		
		tilemap.set_cell(Layers.GLOWING_WIRES_LAYER, neighbor_tile, source_id, atlas_coords, ALT_TILE_ID)
		
		if devices.has(neighbor_tile):
			devices[neighbor_tile].activate()
		
		glowing_tiles[neighbor_tile] = true
		fill_tile(neighbor_tile)

func get_neighbors_pos(tile_pos: Vector2i) -> Array[Vector2i]:
	var neighbors: Array = [Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0)]
	neighbors_pos.clear()
	
	for neighbor in neighbors:
		if not tilemap:
			return []
		
		if tilemap.get_cell_source_id(Layers.WIRE_LAYER, tile_pos + neighbor) != -1:
			neighbor_tile_pos = tile_pos + neighbor
			neighbors_pos.append(neighbor_tile_pos)
	
	return neighbors_pos

func get_cells_in_area(area: Area2D) -> Array[Vector2]: return []

func area_has_broken_wires(area: Area2D) -> bool:
	var collision_shape = area.get_node("CollisionShape2D")
	var shape_extents = collision_shape.shape.extents
	var area_rect = Rect2(area.global_position - shape_extents, shape_extents * 2)
	
	for cell in tilemap.get_used_cells(Layers.BROKEN_WIRES_LAYER):
		var cell_position = tilemap.map_to_local(cell)
		if not area_rect.has_point(cell_position):
			continue
		
		return false
	
	emit_signal("wires_connected", area)
	return true
