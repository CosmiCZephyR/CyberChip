class_name SvManage
extends Node

signal request_save(resource: LevelResource)

# Enum obviously for special types of objects
enum ObjectType {
	OBJECT,
	DOOR,
	RES,
	HUY = -1
}

@onready var res: LevelResource

var registred_objects: Array

func _ready() -> void:
	GameSaver.request_load.connect(_on_load_requested)
	if get_tree().current_scene.get("save_resource"):
		res = get_tree().current_scene.save_resource

func register_object(obj: Object) -> void:
	registred_objects.append(obj)

func save_game():
	if !res:
		return
	
	for o in registred_objects:
		if o.get("position"):
			res.objects[o.get_path()] = {"position": o.position} 
		
		if o.has_method("get_saveable_properties"):
			res.objects[o.get_path()].merge(o.get_saveable_properties())
		
		if o is PlayerRes:
			res.set_player_resouce(o)
	
	emit_signal(&"request_save", res)

func _on_load_requested(resource: LevelResource):
	for o in resource.objects:
		var obj = get_node_or_null(o)
		
		if !obj:
			return
		
		for property in resource.objects[o]:
			obj.set(property, resource.objects[o][property])
