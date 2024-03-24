extends Control

@onready var continue_btn = $TextureRect/ContinueButton
@onready var exit_btn = $TextureRect/ExitButton

func _ready() -> void:
	continue_btn.button_down.connect(_on_continue_pressed)
	exit_btn.button_down.connect(_on_exit_pressed)

func _on_continue_pressed() -> void:
	GameSaver.load_res()
	visible = false

func _on_exit_pressed() -> void:
	visible = false
	get_tree().change_scene_to_file("res://Menus/MAIN_MENU.tscn")
