extends GridContainer

var inventory = preload("res://resources/Inventory.tres")

func _ready() -> void:
#	inventory.items_changed.connect(_on_items_changed)
	setup_items_slots()

func setup_items_slots():
	for item_index in inventory.items.size():
		update_inventory_slot_display(item_index)

func update_inventory_slot_display(item_index: int):
	
	#inventory должен быть метод
	var inventory_slot_display := get_child(item_index)
	var item = inventory.items[item_index]
	
	inventory_slot_display.item_data = item

#func _on_items_changed(indexes) -> void:
#	for item_index in indexes:
#		update_inventory_slot_display(item_index)
