extends Area2D


func _ready() -> void:
	SaveManager.register_object(self)
	InputHandler.save.connect(_on_save_pressed)

func _on_save_pressed():
	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			SaveManager.save_game()
