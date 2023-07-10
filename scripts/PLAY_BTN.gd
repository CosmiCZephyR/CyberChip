extends TextureButton

func _ready():
	button_down.connect(self._change_scene)

func _change_scene() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/AAAAAAAAAAAAAA.tscn")
