extends Node

class_name Repairing

var tile_pos: Vector2i
var tile_atlas_coords: Vector2i
var new_tile_atlas_coords: Vector2i
var tile_id: int
var new_tile_id: int
var atlas_coords_dict: Dictionary = {
	Vector2i(9, 5) : Vector2i(9, 7),
	Vector2i(8, 5) : Vector2i(8, 7),
	Vector2i(8, 4) : Vector2i(9, 6),
	Vector2i(9, 4) : Vector2i(9, 8),
}

func is_necessary_tile(id, atlas_coords, coords_dict):
	return id == 2 and atlas_coords in coords_dict

func activate_repairing(_tilemap: TileMap, master: CharacterBody2D) -> void:
	tile_pos = _tilemap.local_to_map(master.position)
	tile_id = _tilemap.get_cell_source_id(WiresManager.Layers.BROKEN_WIRES_LAYER, tile_pos)
	tile_atlas_coords = _tilemap.get_cell_atlas_coords(2, tile_pos)
	
	if is_necessary_tile(tile_id, tile_atlas_coords, atlas_coords_dict):
		print_debug("huyqq")
		new_tile_atlas_coords = atlas_coords_dict[tile_atlas_coords]
		new_tile_id = 1
		_tilemap.set_cell(WiresManager.Layers.BROKEN_WIRES_LAYER, tile_pos, -1)
		_tilemap.set_cell(WiresManager.Layers.WIRE_LAYER, tile_pos, new_tile_id, new_tile_atlas_coords)
	
	WiresManager.area_has_broken_wires(master._current_room)
