class_name Inventory
extends Resource

signal items_changed(indexes)

@export var items: Array[Resource] = [
	null, null, null, null, null, null, null, null, null, null, null, null
]

#@warning_ignore()
func duplicate_r(_flag: bool = false) -> Resource:
	var _douplicate = duplicate(_flag)
	
	for idx in range(items.size()):
		if items[idx]:
			_douplicate.items[idx] = items[idx].duplicate(true)
	
	return _douplicate

func get_item_on_index(item_index: int) -> Item:
	return items[item_index]

func set_item(item_index: int, item: Resource) -> Resource:
	var previous_item: Resource = items[item_index]
	items[item_index] = item
	emit_signal("items_changed", [item_index])
	return previous_item

func swap_items(item_index_for_change: int, drop_data) -> void:
	var target_item_index = drop_data.item_index
	var item: Resource = items[item_index_for_change]
	
	drop_data.inventory_res.set_item(target_item_index, item)
	
	items[item_index_for_change] = drop_data.item
	
	emit_signal("items_changed", [item_index_for_change, target_item_index])

func remove_item(item_index: int) -> Resource:
	var previous_item: Resource = items[item_index]
	
	if previous_item:
		previous_item = previous_item.duplicate(true)
	
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return previous_item
