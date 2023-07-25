extends Sprite2D

func _physics_process(_delta: float) -> void:
	position.x += 5

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
