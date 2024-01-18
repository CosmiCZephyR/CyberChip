extends TextureButton

func _ready():
	pressed.connect(self._quit_game)

func _quit_game():
	get_tree().quit()
