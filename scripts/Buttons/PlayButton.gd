extends TextureButton

const level = preload("res://scenes/TestLevel.tscn")

func _ready():
	button_down.connect(_change_scene)

func _change_scene() -> void:
	get_tree().change_scene_to_packed(level)
