extends CenterContainer

var inventory = preload("res://resources/Inventory.tres")
var item_data = null : set = set_item

func set_item(value):
	item_data = value
	draw_item()


const TILE_MAP_RECT = Rect2i(0, 0, 144, 192)
@onready var tile_map: TileMap = get_tree().get_first_node_in_group("Tilemaps")
@onready var item_texture_rect = $ItemTextureRect

#func _physics_process(delta):
#	print(TILE_MAP_RECT.has_point(get_global_mouse_position()))

#func _ready():
#	var _colums = get_parent().columns
#	var _vec_pos = Vector2i(get_index() % _colums, get_index() / _colums)
#	var _idx_pos = _vec_pos.y * _colums + _vec_pos.x
#	prints("#", name, 'pos' , _vec_pos, _idx_pos)

func draw_item():
	if item_data is Item:
		item_texture_rect.texture = item_data.texture
	else:
		item_texture_rect.texture = load("res://sprites/Slot.png")

# pickup item
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
		item_data = null
		
		return data

# can_drop item
func _can_drop_data(at_position, data):
	return data is Dictionary and data.has("item")

# drop item
func _drop_data(at_position, droped_data):
	var my_item_index = get_index()
	var my_item = inventory.items[my_item_index]
	
	inventory.swap_items(my_item_index, droped_data.item_index)
	inventory.set_item(my_item_index, droped_data.item)
	
	var _prev_slot = get_parent().get_child(droped_data.item_index)
	_prev_slot.item_data = item_data
	item_data = droped_data.item
