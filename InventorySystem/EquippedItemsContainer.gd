class_name EquippedItemsContainer
extends TileMap
 
@export var inventory: Inventory #= Inventory.new()
var _available_slots = []

#var resistor: PackedScene = preload("res://components/resistor/resistor.tscn")
#var transistor: PackedScene = preload("res://components/capacitor/capacitor.tscn")

func _ready() -> void:
	inventory.size = _available_slots.size()
	
	if not inventory:
		inventory = load("res://InventorySystem/Resouces/Inventory.tres").duplicate_r(true)
	_setup_input_handler()
	_setup_inventory()
	# HACK:
#	_spawn_item_at_tile(resistor, Vector2i(1, 2))
#	_spawn_item_at_tile(transistor, Vector2i(3, 2))

func _setup_input_handler():
	$DragNDropInputHandler.position = get_used_rect().position * tile_set.tile_size
	$DragNDropInputHandler.size = get_used_rect().size * tile_set.tile_size

func get_item_from_slot(_local_tile_pos):
	var _item_idx = _available_slots.find(_local_tile_pos)
	if _item_idx != -1:
		return inventory.items[_item_idx]
	else: 
		return null

func _setup_inventory():
	# TODO: Несортированный массив!
	_available_slots = get_used_cells(0)
	
	_setup_items_slots()
	
	
#	inventory.items_changed.connect(_on_items_updated)
	pass

func _setup_items_slots() -> void:
	for item_index in inventory.items.size():
		if inventory.items[item_index]:
			_spawn_item_at_tile(inventory.items[item_index].source_scene, _available_slots[item_index])
#		_update_inventory_slot_display(item_index)
#		get_child(item_index).inventory = inventory

#func _update_inventory_slot_display(item_index: int) -> void:
#	var _inventory_slot_display = get_child(item_index)
#	var _item: Item = inventory.get_item_on_index(item_index)
#
#	_inventory_slot_display.item_data = _item

#func _on_items_updated(indexes):
#	for item in indexes:
#		get_child(item).item_data = inventory.items[item]
#		pass

func _spawn_item_at_tile(spawning_item: PackedScene, tile_position: Vector2i):
	var local_position = map_to_local(tile_position)
	var scene_instance = spawning_item.instantiate()
	scene_instance.position = local_position
	add_child(scene_instance)
