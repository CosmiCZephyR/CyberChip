extends Area2D

class_name Transistor

var is_on: bool = false

@onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready():
	_animation.seek(0.2)
	body_entered.connect(self._interaction)

func _interaction(_body):
	if _body.is_in_group("Player"):
		Event.emit_signal("transistor_activated", self)
		print_debug("Signal emmited")

func toggle():
	if is_on:
		_animation.play("Off")
		is_on = not is_on
	else:
		_animation.play_backwards("Off")
		is_on = not is_on

func get_state():
	return is_on
