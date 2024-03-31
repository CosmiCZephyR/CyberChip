extends Control

@onready var continue_btn = $TextureRect/ContinueButton
@onready var exit_btn = $TextureRect/ExitButton

func _ready() -> void:
	continue_btn.button_down.connect(_on_continue_pressed)
	exit_btn.button_down.connect(_on_exit_pressed)

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/TestLevel.tscn")

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/MAIN_MENU.tscn")
