extends AnimationPlayer

func _on_animation_finished(_self):
	get_tree().change_scene_to_file("res://Menus/MAIN_MENU.tscn")
