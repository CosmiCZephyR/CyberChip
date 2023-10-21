extends CenterContainer

var inventory = preload("res://resources/Inventory.tres")

const DISTANCE_TO_TILE_MAP = 150

@onready var tile_map = get_tree().get_first_node_in_group("Tilemaps")
@onready var item_texture_rect = $ItemTextureRect

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
		
		set_drag_preview(drag_preview)
		
		return data

func _can_drop_data(at_position, data):
	if at_position.to_global() < DISTANCE_TO_TILE_MAP:
		
		pass
	return data is Dictionary and data.has("item")

func _drop_data(at_position, data):
	var my_item_index = get_index()
	var my_item = inventory.items[my_item_index]
	
	inventory.swap_items(my_item_index, data.item_index)
	inventory.set_item(my_item_index, data.item)
