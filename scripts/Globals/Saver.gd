extends Node
class_name Saver

const SAVE_FILE_PATH = "C:/Клондайк/SavesTest/sav.tres"

@onready var level: Level = get_tree().current_scene.get_node("/root/TestScene")

func load_game_data() -> Resource:
	if ResourceLoader.exists(SAVE_FILE_PATH, "tres"):
		return load(SAVE_FILE_PATH)
	return null

func save_game_data(data: LevelResource) -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string("")
	file.close()
	var result = ResourceSaver.save(data, SAVE_FILE_PATH)
	assert(result == OK)
