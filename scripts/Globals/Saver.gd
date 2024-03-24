extends Node
class_name Saver

signal request_load(res: LevelResource)

const SAVE_FILE_PATH = "E:/Saves/sav.tres"

func _ready() -> void:
	SaveManager.request_save.connect(_on_save_requested)
	
	if FileAccess.file_exists(SAVE_FILE_PATH):
		print("save file exists")
	else:
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		file.store_string("")
		file.close()

func load_res() -> void:
	if ResourceLoader.exists(SAVE_FILE_PATH, "tres"):
		#print_debug(inst_to_dict(ResourceLoader.load(SAVE_FILE_PATH)))
		emit_signal(&"request_load", ResourceLoader.load(SAVE_FILE_PATH))
	else:
		emit_signal(&"request_load", null)

func _on_save_requested(data: LevelResource) -> void:
	#print_debug(inst_to_dict(data))
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string("")
	file.close()
	var result = ResourceSaver.save(data, SAVE_FILE_PATH)
	assert(result == OK)
