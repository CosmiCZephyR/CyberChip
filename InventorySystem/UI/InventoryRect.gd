extends ColorRect

var inventory = preload("res://InventorySystem/Resouces/Resources/Inventory.tres")

func _can_drop_data(_at_position, data) -> bool:
	return data is Dictionary and data.has("item")

func _drop_data(_at_position, data) -> void:
	inventory.set_item(data.item_index, data.item)
