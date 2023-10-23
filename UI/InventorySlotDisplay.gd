extends CenterContainer

var inventory = preload("res://resources/Inventory.tres")

const TILE_MAP_RECT = Rect2i(0, 0, 144, 192)

@onready var tile_map: TileMap = get_tree().get_first_node_in_group("Tilemaps")
@onready var item_texture_rect = $ItemTextureRect

#func _physics_process(delta):
#	print(TILE_MAP_RECT.has_point(get_global_mouse_position()))

func display_item(item):
	if item is Item:
		item_texture_rect.texture = item.texture
	else:
		item_texture_rect.texture = load("res://sprites/Slot.png")

func _get_drag_data(at_position):
	var item_index = get_index()
	var item = inventory.remove_item(item_index)
	
	if item is Item:
		var data = {}
		data.item = item
		data.item_index = item_index
		
		var drag_preview = TextureRect.new()
		drag_preview.texture = item.texture
		drag_preview.position = Vector2.ZERO
		
		set_drag_preview(drag_preview)
		
		return data

func _can_drop_data(at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(at_position, data):
	var my_item_index = get_index()
	var my_item = inventory.items[my_item_index]
	
	if TILE_MAP_RECT.has_point(get_global_mouse_position()):
		var item_index = get_index()
		var item = inventory.items[item_index]
		
		at_position = tile_map.local_to_map(tile_map.map_to_local(at_position))
		print(at_position)
	else:
		inventory.swap_items(my_item_index, data.item_index)
		inventory.set_item(my_item_index, data.item)
