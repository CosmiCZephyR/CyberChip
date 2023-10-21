extends Area2D

var flag: bool = false

var speed_modifier: float = 0.666
var normal_speed: float = 65

var cosuki_modifier: float = 0.75

func _ready():
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)
#	self.mouse_entered.connect(self._mouse_entered)

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and not flag:
			body.current_kosuki *= cosuki_modifier
			flag = true

func _body_entered(body):
	if body.is_in_group("Player"):
		body.speed *= speed_modifier

func _body_exited(body):
	if body.is_in_group("Player"):
		body.speed = normal_speed
