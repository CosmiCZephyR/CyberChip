extends CenterContainer

@onready var _item_texture_rect = $ItemTextureRect
@warning_ignore("unused_private_class_variable")
@onready var _tile_map: TileMap = get_tree().get_first_node_in_group("Tilemaps")

var inventory: Inventory = preload("res://InventorySystem/Resouces/Inventory.tres")
var item_data = null : set = set_item

# Vector and index position of items and convert them
# index = get_index()
# columns = get_parent().columns
# vector_position = Vector2i(index % columns, index / columns)
# index_position = vector_position.y * columns + vector_position.x

func set_item(value):
	item_data = value
	_draw_item()

func _draw_item() -> void:
	if item_data is Item:
		_item_texture_rect.texture = item_data.texture
	else:
		_item_texture_rect.texture = load("res://sprites/Slot.png")

# pickup item
@warning_ignore("unused_parameter")
func _get_drag_data(at_position):
	var _item_index = get_index()
	var _item = inventory.remove_item(_item_index)
	
	if _item is Item:
		var data = {}
		data.item = _item
		data.item_index = _item_index
		
		var _drag_preview = TextureRect.new()
		_drag_preview.texture = _item.texture
		_drag_preview.position = Vector2.ZERO
		
		set_drag_preview(_drag_preview)
		item_data = null
		
		return data

# can drop item
@warning_ignore("unused_parameter")
func _can_drop_data(at_position, data) -> bool:
	return data is Dictionary and data.has("item")

# drop item
@warning_ignore("unused_parameter")
func _drop_data(at_position, droped_data) -> void:
	var _my_item_index = get_index()
	var _my_item = inventory.get_item_on_index(_my_item_index)
	
	inventory.swap_items(_my_item_index, droped_data.item_index)
	inventory.set_item(_my_item_index, droped_data.item)
	
	var _previous_slot = get_parent().get_child(droped_data.item_index)
	_previous_slot.item_data = item_data
	item_data = droped_data.item
