extends TextureButton

# Eto polnaya pizda
@onready var player = get_parent().get_parent().get_parent().get_parent().get_parent()

func _ready() -> void:
	button_down.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	player.paused = false
