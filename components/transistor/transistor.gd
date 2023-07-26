extends Area2D

class_name Transistor

var is_on: bool = false

@onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready():
	_animation.seek(0.2)
	body_entered.connect(self._interaction)

func _interaction(_body) -> void:
	if _body.is_in_group("Player"):
		Event.emit_signal("transistor_selected", self)

func toggle() -> void:
	if !player_in_zone():
		return
	if is_on:
		_animation.play("Off")
		is_on = not is_on
	else:
		_animation.play_backwards("Off")
		is_on = not is_on
	Event.emit_signal("transistor_activated", self)

func get_state() -> bool:
	return is_on

func player_in_zone() -> bool:
	var final_flag := false
	var all_bodies = get_overlapping_bodies()
	for body in all_bodies:
		final_flag = final_flag || body.is_in_group("Player")
	
	return final_flag
