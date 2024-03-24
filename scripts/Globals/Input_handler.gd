extends Node

signal dash
signal save 
signal pause
signal attack
signal movement
signal magnetism
signal repairing
signal interaction
signal electroShock
signal magneticShock

var actions: Dictionary = {
	"movement"      : Callable(Input, "is_action_pressed"),
	"magnetism"     : Callable(Input, "is_action_pressed"),
	"repairing"     : Callable(Input, "is_action_just_pressed"),
	"save"          : Callable(Input, "is_action_just_pressed"),
	"pause"         : Callable(Input, "is_action_just_pressed"),
	"attack"        : Callable(Input, "is_action_just_pressed"),
	"interaction"   : Callable(Input, "is_action_just_pressed"),
	"magneticShock" : Callable(Input, "is_action_just_pressed"),
}

# Double click di
var _max_double_click_time: float = 500
var _last_key_press_time: float = 0.0
var _key_code: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_type():
		for action in actions:
			if event.is_action(action, false):
				event_signal_emit(action)
	
	if event is InputEventKey and event.pressed:
		var current_time: int = Time.get_ticks_msec()
		
		if is_double_click(event):
			emit_signal("dash")
		
		_last_key_press_time = current_time
		_key_code = event.get_keycode()

func is_double_click(e: InputEvent):
	var current_time: int = Time.get_ticks_msec()
	return current_time - _last_key_press_time < _max_double_click_time and e.get_keycode() == _key_code and not e.is_echo()

func event_signal_emit(action: String):
	if action in actions and actions[action].call(action):
		emit_signal(action)
