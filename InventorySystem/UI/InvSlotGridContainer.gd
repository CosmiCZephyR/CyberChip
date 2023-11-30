extends GridContainer

@export var inventory: Inventory

func _ready() -> void:
	if not inventory:
		inventory = load("res://InventorySystem/Resouces/NonEquipped/Resources/Inventory.tres").duplicate_r(true)
	_setup_inventory()

func _setup_inventory():
	_setup_items_slots()
	inventory.items_changed.connect(_on_items_updated)
	pass

func _setup_items_slots() -> void:
	for item_index in inventory.items.size():
		_update_inventory_slot_display(item_index)
		get_child(item_index).inventory = inventory

func _update_inventory_slot_display(item_index: int) -> void:
	var _inventory_slot_display = get_child(item_index)
	var _item: Item = inventory.get_item_on_index(item_index)
	
	_inventory_slot_display.item_data = _item

func _on_items_updated(indexes):
	for item in indexes:
#		if item:
#			inventory.items[item]._draw_item()
		get_child(item).item_data = inventory.items[item]
		pass
