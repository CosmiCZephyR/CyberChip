class_name Inventory
extends Resource

signal items_changed(indexes)

@export var items: Array[Resource] = [
	null, null, null, null, null, null, null, null, null, null, null, null
]

func get_item_on_index(item_index: int) -> Item:
	return items[item_index]

func set_item(item_index: int, item: Resource) -> Resource:
	var previous_item: Resource = items[item_index]
	items[item_index] = item
	emit_signal("items_changed", [item_index])
	return previous_item

func swap_items(item_index: int, target_item_index: int) -> void:
	var target_item: Resource = items[target_item_index]
	var item: Resource = items[item_index]
	
	items[target_item_index] = item
	items[item_index] = target_item
	
	emit_signal("items_changed", [item_index, target_item_index])

func remove_item(item_index: int) -> Resource:
	var previous_item: Resource = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return previous_item
