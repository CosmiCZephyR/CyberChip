extends Node

signal magnetism
signal movement
signal repairing
signal interaction
signal electroShock
signal attack
signal dash

var actions: Array = [
	"magnetism",
	"movement",
	"repairing",
	"interaction",
	"electroShock",
	"attack"
]

var max_double_click_time: float = 500
var last_key_press_time: float = 0.0
var key_code: int = 0

func _input(event):
	if event.is_action_type():
		for action in actions:
			if event.is_action(action, false):
				event_signal_emit(action)
	
	if event is InputEventKey and event.pressed:
		var current_time := Time.get_ticks_msec()
		if is_double_click(event):
			emit_signal("dash")
		last_key_press_time = current_time
		key_code = event.get_keycode()

func is_double_click(e):
	var current_time := Time.get_ticks_msec()
	return current_time - last_key_press_time < max_double_click_time and e.get_keycode() == key_code and not e.is_echo()

func event_signal_emit(action: String):
	match action:
		"magnetism":
			if Input.is_action_pressed(action):
				emit_signal("magnetism")
		
		"movement":
			if Input.is_action_pressed(action):
				emit_signal("movement")
		
		"repairing":
			if Input.is_action_just_pressed(action):
				emit_signal("repairing")
		
		"interaction":
			if Input.is_action_just_pressed(action):
				emit_signal("interaction")
		
		"electroShock":
			if Input.is_action_just_pressed(action):
				emit_signal("electroShock")
		
		"attack":
			if Input.is_action_just_pressed(action):
				emit_signal("attack")
