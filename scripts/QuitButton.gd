extends TextureButton

func _ready() -> void:
	button_down.connect(_change_scene)

func _change_scene() -> void:
	get_tree().change_scene_to_file("res://Menus/MAIN_MENU.tscn")
