extends Area2D

func _ready() -> void:
	add_to_group("rooms")
	body_entered.connect(self._on_room_entered)

func _on_room_entered(_entered_body) -> void:
	await get_tree().create_timer(0.1).timeout
	if _entered_body.is_in_group("Player"):
		_entered_body.set_current_room(self)
