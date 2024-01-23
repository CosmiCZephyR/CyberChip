extends Node

class_name Repairing

var tile_pos: Vector2i
var tile_atlas_coords: Vector2i
var new_tile_atlas_coords: Vector2i
var tile_id: int
var new_tile_id: int
var atlas_coords_dict: Dictionary = {
	Vector2i(6, 2) : Vector2i(4, 1),
	Vector2i(7, 2) : Vector2i(4, 0),
	Vector2i(7, 3) : Vector2i(6, 1),
	Vector2i(7, 4) : Vector2i(7, 1),
	Vector2i(6, 4) : Vector2i(7, 0),
	Vector2i(5, 4) : Vector2i(6, 0)
}

func is_necessary_tile(id, atlas_coords, coords_dict):
	return id == 1 and atlas_coords in coords_dict

func activate_repairing(_tilemap: TileMap, master: CharacterBody2D) -> void:
	tile_pos = _tilemap.local_to_map(master.position)
	tile_id = _tilemap.get_cell_source_id(2, tile_pos)
	tile_atlas_coords = _tilemap.get_cell_atlas_coords(2, tile_pos)
	
	if is_necessary_tile(tile_id, tile_atlas_coords, atlas_coords_dict):
		new_tile_atlas_coords = atlas_coords_dict[tile_atlas_coords]
		new_tile_id = 1
		_tilemap.set_cell(2, tile_pos, -1)
		_tilemap.set_cell(1, tile_pos, new_tile_id, new_tile_atlas_coords)
	
	WiresManager.area_has_broken_wires(master._current_room)
