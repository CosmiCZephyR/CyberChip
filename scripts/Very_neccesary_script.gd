extends Area2D

func _ready():
	add_to_group("rooms")

	body_entered.connect(self._on_room_entered)

func _on_room_entered(_entered_body):
	_entered_body = 10
	await get_tree().create_timer(0.1).timeout
	var bodies: Array = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			var door = get_node("Door")
			body.get_current_room(self, door)
