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
	var final_flag: bool = false
	var all_bodies: Array[Node2D] = get_overlapping_bodies()
	
	for body in all_bodies:
		final_flag = true if body.is_in_group("Player") else final_flag
	
	return final_flag
