extends ColorRect

var inventory = preload("res://InventorySystem/Resouces/Inventory.tres")

func _can_drop_data(at_position, data):
	return data is Dictionary and data.has("item")

func _drop_data(at_position, data):
	inventory.set_item(data.item_index, data.item)
