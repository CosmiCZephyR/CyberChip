extends GridContainer

var inventory: Inventory = preload("res://InventorySystem/Resouces/Inventory.tres")

func _ready() -> void:
	_setup_items_slots()

func _setup_items_slots() -> void:
	for item_index in inventory.items.size():
		_update_inventory_slot_display(item_index)

func _update_inventory_slot_display(item_index: int) -> void:
	var _inventory_slot_display = get_child(item_index)
	var _item: Item = inventory.get_item_on_index(item_index)
	
	_inventory_slot_display.item_data = _item
