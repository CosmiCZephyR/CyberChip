extends Node

signal magnetism
signal repairing
signal interaction
signal shock
signal attack
signal dash

var max_double_click_time: float = 250
var last_key_press_time: float = 0.0
var key_code: int = 0

func _unhandled_input(event):
	if event is InputEventKey: 
		match event:
			"Magnetism":
				emit_signal("magnetism")
			"Repairing":
				emit_signal("repairing")
			"interaction":
				emit_signal("interaction")
			"Magnetic_shock":
				emit_signal("magnetism")
	
	if event is InputEventMouseButton and event.is_action_pressed("attack"):
		emit_signal("attack")
	
	if event is InputEventKey and event.pressed:
		var current_time := Time.get_ticks_msec()
		if is_double_click(event):
			emit_signal("dash")
		last_key_press_time = current_time
		key_code = event.get_keycode() 

func is_double_click(e):
	var current_time := Time.get_ticks_msec()
	return current_time - last_key_press_time < max_double_click_time and e.get_keycode() == key_code and not e.is_echo()
