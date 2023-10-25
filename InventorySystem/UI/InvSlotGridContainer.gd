extends GridContainer

var inventory: Inventory = preload("res://InventorySystem/Resouces/Inventory.tres").duplicate_r(true)

func _ready() -> void:
	_setup_items_slots()
#	inventory.items_changed.connect(_on_items_updated)

func _setup_items_slots(_changed_indexes = []) -> void:
	for item_index in inventory.items.size():
		_update_inventory_slot_display(item_index)

func _update_inventory_slot_display(item_index: int) -> void:
	var _inventory_slot_display = get_child(item_index)
	var _item: Item = inventory.get_item_on_index(item_index)
	
	_inventory_slot_display.item_data = _item

#func _on_items_updated(indexes):
#	for item in indexes:
#		if item:
#			inventory.items[item]._draw_item()
