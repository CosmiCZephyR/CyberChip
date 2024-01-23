extends Node2D
class_name Level

@export var save_resource: LevelResource
@export_global_file var save_path = "user://saves/"

@onready var saver = Saver.new()

func update_values_before_save():
	save_resource.glowing_wires_dict = get_glowing_wires()
	save_resource.player_resource = get_player_resource()
	save_resource.doors_states = get_doors_states()
	save_resource.positions = get_positions()

func apply_loaded_resource_values():
	set_player_resource()
	set_glowing_wires()
	set_doors_states()
	set_positions()

func set_positions() -> void:
	var childrens = get_children(true)
	
	for node in childrens:
		if node is Node2D:
			node.global_position = save_resource.positions[node.get_index(true)]

func get_positions() -> Array[Vector2]:
	var nodes_positions: Array[Vector2]
	var childrens = get_children(true)
	
	for node in childrens:
		if node.name.begins_with("Room"):
			childrens.append_array(node.get_children())
		if node.name == "Door":
			print_debug(node.global_position)
		if node is Node2D:
			nodes_positions.append(node.global_position)
	
	return nodes_positions

func set_doors_states() -> void:
	var rooms = get_children(true).filter(func(node: Node2D):
		return node.name.begins_with("Room")
	)
	
	for room in rooms:
		if room.has_node("Door"):
			var door = room.get_node("Door")
			var door_name = room.name + door.name
			if door.is_open != save_resource.doors_states[door_name]:
				door.absolute_open(door)

func get_doors_states() -> Dictionary:
	var doors_states: Dictionary
	var rooms = get_children(true).filter(func(node: Node2D):
		return node.name.begins_with("Room")
	)
	
	for room in rooms:
		if room.has_node("Door"):
			var door = room.get_node("Door")
			var door_name = room.name + door.name
			doors_states[door_name] = door.is_open
	
	print_debug(doors_states)
	return doors_states

func set_player_resource() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.save_resource = save_resource.player_resource

func get_player_resource() -> PlayerRes:
	var player = get_tree().get_first_node_in_group("Player")
	return player.save_resource

func set_glowing_wires() -> void:
	var manager = WiresManager
	manager.glowing_tiles = save_resource.glowing_wires_dict

func get_glowing_wires() -> Dictionary:
	var manager = WiresManager
	return manager.glowing_tiles

