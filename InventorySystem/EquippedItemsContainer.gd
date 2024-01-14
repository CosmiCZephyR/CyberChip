class_name EquippedItemsContainer
extends TileMap

## This class is the visual representation of equipped items and has all functionality 
## and members to interaction with equipped items 

## This is the resource of inventory with the equipped items
@export var inventory: Inventory

## This member contains all available slots
var _available_slots: Array[Vector2i]

#TODO: сделать систему сохранения. Кажется, через инвентарь будет проще
#TODO: реализовать своп предметов
func _ready() -> void:
	inventory.size = _available_slots.size()
	
	if not inventory:
		inventory = load("res://InventorySystem/Resouces/Inventory.tres").duplicate_r(true)
	
	_setup_input_handler()
	_setup_inventory()

## Setups drag and drop input handler. (called when ready)
func _setup_input_handler() -> void:
	$DragNDropInputHandler.position = get_used_rect().position * tile_set.tile_size
	$DragNDropInputHandler.size = get_used_rect().size * tile_set.tile_size

## Setups inventory, it's slots and items. (called when ready)
func _setup_inventory() -> void:
	_available_slots = get_used_cells(0)
	_available_slots.sort_custom(_vector_sort_by_x)
	_setup_items_slots()

## Returns the value of the 
func get_item_from_slot(_local_tile_pos) -> Item:
	var _item_idx: int = _available_slots.find(_local_tile_pos)
	
	if _item_idx != -1:
		return inventory.items[_item_idx]
	
	return null

## Sort vectors by it's x value.
func _vector_sort_by_x(a: Vector2i, b: Vector2i) -> bool:
	if a.y == b.y:
		return a.x < b.x
	else:
		return a.y < b.y

## In first time scene launch setups items slots
func _setup_items_slots() -> void:
	for item_index in inventory.items.size():
		if inventory.items[item_index]:
			spawn_item_at_tile(inventory.items[item_index].source_scene, _available_slots[item_index])

## Spawn given item at given tile.
# ДУБЛИРОВАНИЕ!
func spawn_item_at_tile(spawning_item: PackedScene, tile_position: Vector2i) -> void:
	var local_position = map_to_local(tile_position)
	var scene_instance = spawning_item.instantiate()
	scene_instance.tile_items_container = self
	scene_instance.position = local_position
	$DragNDropInputHandler.add_child(scene_instance)

## Delete item at the given tile
## @experimental
func _delete_item_at_tile(tile_position: Vector2i) -> void:
	var item_to_delete = get_item_from_slot(tile_position)
	item_to_delete.queue_free()
