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

@warning_ignore("shadowed_variable_base_class")
func activate_repairing(_tilemap: TileMap, owner) -> void:
	var tile_info = get_tile_info(_tilemap, tile_pos)
	tile_id = tile_info[0]
	tile_atlas_coords = tile_info[1]
	tile_pos = get_tile_position(_tilemap, owner)
	if is_necessary_tile(tile_id, tile_atlas_coords, atlas_coords_dict):
		replace_tile(_tilemap, tile_pos, atlas_coords_dict[tile_atlas_coords])

func get_tile_position(_tilemap: TileMap, owner) -> Vector2:
	return _tilemap.local_to_map(owner.position)

func get_tile_info(_tilemap: TileMap, tile_pos: Vector2) -> Array:
	return [_tilemap.get_cell_source_id(2, tile_pos), _tilemap.get_cell_atlas_coords(2, tile_pos)]

func replace_tile(_tilemap: TileMap, tile_pos: Vector2, new_tile_atlas_coords: Vector2) -> void:
	new_tile_id = 1
	_tilemap.set_cell(2, tile_pos, -1)
	_tilemap.set_cell(1, tile_pos, new_tile_id, new_tile_atlas_coords)

