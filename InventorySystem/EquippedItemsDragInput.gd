extends Control

@onready var _tilemap: TileMap = get_parent()

func _can_drop_data(at_position, data) -> bool:
	return can_drop_item(at_position, data)

func can_drop_item(at_position, data) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(at_position, data) -> void:
	drop_item(at_position, data)

# ДУБЛИРОВАНИЕ С ТАЙЛМАП СКРИПТОМ, ОБОБЩИТЬ
# TODO: Добавить сохранение
func drop_item(at_position, data) -> void:
	var scene = data.item_scene
	var scene_instance = scene.instantiate()
	scene_instance.tile_items_container = _tilemap
	scene_instance.position = _tilemap.map_to_local(_tilemap.local_to_map(get_local_mouse_position()))
	add_child(scene_instance)
