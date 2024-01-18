class_name Transistor
extends Area2D

## This class is the representation of the transistor.
## It's work very simple

## This is the controller of the state
var is_on: bool = false

@onready var _animation: AnimationPlayer = $AnimationPlayer

func _ready():
	_animation.seek(0.2)
	body_entered.connect(self._interaction)

## This mehtod is called when player select this transistor
func _interaction(_body) -> void:
	if _body.is_in_group("Player"):
		Event.emit_signal("transistor_selected", self)

func toggle() -> void:
	if not player_in_zone():
		return
	if is_on:
		_animation.play("Off")
		is_on = not is_on
	else:
		_animation.play_backwards("Off")
		is_on = not is_on
	
	Event.emit_signal("transistor_activated", self)

# this method returns current transistor's state 
func get_state() -> bool:
	return is_on

# this method emit signal if player in zone
func player_in_zone() -> bool:
	var final_flag: bool = false
	var all_bodies: Array[Node2D] = get_overlapping_bodies()
	
	for body in all_bodies:
		final_flag = true if body.is_in_group("Player") else final_flag
	
	return final_flag
