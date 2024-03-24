class_name Room
extends Area2D

func _ready() -> void:
	await get_parent().ready
	SaveManager.register_object(self)
	
	add_to_group("rooms")
	body_entered.connect(_on_room_entered)
	body_exited.connect(_on_room_exited)

func _on_room_entered(_entered_body) -> void:
	if _entered_body.is_in_group("Player"):
		_entered_body.set_current_room(self)
		
		if has_node("PCam" + name):
			get_node("PCam" + name).set_priority(10)

func _on_room_exited(_exited_body) -> void:
	if _exited_body.is_in_group("Player"):
		if has_node("PCam" + name):
			get_node("PCam" + name).set_priority(0)
