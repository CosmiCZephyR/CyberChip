extends Node
class_name Saver

const SAVE_FILE_PATH = "C:/Клондайк/SavesTest/sav.tres"

@onready var level: Level = get_tree().current_scene.get_node("/root/TestScene")

func _ready() -> void:
	await get_node_or_null("/root/TestScene").ready

	#load_file = save_file.trim_suffix("sav.save")

func load_game_data() -> Resource:
	if ResourceLoader.exists(SAVE_FILE_PATH):
		return ResourceLoader.load(SAVE_FILE_PATH, "tres")
	return null

func save_game_data(data) -> void:
	print(inst_to_dict(data))
	ResourceSaver.save(data, SAVE_FILE_PATH)
