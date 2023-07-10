extends AnimationPlayer

func _on_animation_finished(_self):
	get_tree().change_scene_to_file("res://SCENES/MAIN_MENU.tscn")
	pass # Replace with function body.
