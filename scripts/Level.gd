extends Node2D
class_name Level

@export var save_resource: LevelResource
@export_global_file var save_path = "user://saves/"

@onready var saver = Saver.new()

#func _ready() -> void:
	#save_resource.glowing_wires_dict = get_glowing_wires()
	#save_resource.player_resource = get_player_resource()
	#save_resource.positions = get_positions()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		save_resource.glowing_wires_dict = get_glowing_wires()
		save_resource.player_resource = get_player_resource()
		save_resource.positions = get_positions()
		saver.save_game_data(save_resource)
	if Input.is_action_just_pressed("load"):
		save_resource = saver.load_game_data()
		load_setter()

func load_setter():
	set_glowing_wires()
	set_player_resource()
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
		if node.is_in_group("Player"):
			print("PLAYER POSITION IS",node.global_position)
		if node is Node2D:
			nodes_positions.append(node.global_position)
	
	return nodes_positions

func get_player_resource() -> PlayerRes:
	var player = get_tree().get_first_node_in_group("Player")
	return player.save_resource

func set_player_resource() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.save_resource = save_resource.player_resource

func get_glowing_wires() -> Dictionary:
	var manager = WiresManange
	return manager.glowing_tiles

func set_glowing_wires() -> void:
	var manager = WiresManange
	manager.glowing_tiles = save_resource.glowing_wires_dict
