class_name MainInventory
extends Node2D

var items: Array

var dragging = false
var mouse_button_pressed = false

@onready var current_item: GovnoItem

func _process(_delta):
	if dragging and mouse_button_pressed:
		var mouse_pos = get_local_mouse_position()
		current_item.global_position = mouse_pos

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_button_pressed = true
	elif event is InputEventMouseButton and not event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_button_pressed = false
		dragging = false

func get_current_item(item: GovnoItem) -> void:
	current_item = item

func on_mouse_entered():
	dragging = true

func on_mouse_exited():
	dragging = false
