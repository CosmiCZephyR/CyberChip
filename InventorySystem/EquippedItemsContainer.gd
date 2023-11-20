class_name EquippedItemsContainer
extends TileMap
 
var inventory: Inventory = preload("res://InventorySystem/Resouces/Inventory.tres")

var resistor: PackedScene = preload("res://components/resistor/resistor.tscn")
var transistor: PackedScene = preload("res://components/capacitor/capacitor.tscn")

func _ready():
	_spawn_item_at_tile(resistor, Vector2i(1, 2))
	_spawn_item_at_tile(transistor, Vector2i(3, 2))

func _process(delta):
	pass

func _spawn_item_at_tile(spawning_item: PackedScene, tile_position: Vector2i):
	var local_position = map_to_local(tile_position)
	var scene_instance = spawning_item.instantiate()
	scene_instance.position = local_position
	add_child(scene_instance)
