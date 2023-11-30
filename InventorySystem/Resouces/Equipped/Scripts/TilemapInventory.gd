class_name EquippedIneventory
extends Resource

# If you can imagine the worst DRY infringement, then you're wrong.
# This is it, the wrost DRY infringement

@export var equipped_items: Array[EquippedItem]
var size: int

func _init(_size = 99):
	size = _size
	_setup(size)

func _setup(_arr_size):
	for idx in equipped_items:
		equipped_items[idx] = null

func duplicate_r(_flag: bool = false) -> Resource:
	var _douplicate = duplicate(_flag)
	
	for idx in range(equipped_items.size()):
		if equipped_items[idx]:
			_douplicate.equipped_items[idx] = equipped_items[idx].duplicate(true)
	
	return _douplicate

func get_item_on_index(item_index: int) -> EquippedItem:
	return equipped_items[item_index]

func set_item(item_index: int, item: Resource) -> Resource:
	var previous_item: Resource = equipped_items[item_index]
	equipped_items[item_index] = item
	emit_signal("equipped_items_changed", [item_index])
	return previous_item

func swap_equipped_items(item_index_for_change: int, drop_data) -> void:
	var target_item_index = drop_data.item_index
	var item: Resource = equipped_items[item_index_for_change]
	
	drop_data.inventory_res.set_item(target_item_index, item)
	
	equipped_items[item_index_for_change] = drop_data.item
	
	emit_signal("equipped_items_changed", [item_index_for_change, target_item_index])

func remove_item(item_index: int) -> Resource:
	var previous_item: Resource = equipped_items[item_index]
	
	if previous_item:
		previous_item = previous_item.duplicate(true)
	
	equipped_items[item_index] = null
	emit_signal("equipped_items_changed", [item_index])
	return previous_item
