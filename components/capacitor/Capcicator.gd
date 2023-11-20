extends Area2D

var item

var speed_modifier: float = 1.333
var normal_speed: float = 65

func _ready():
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func _body_entered(body):
	if body.is_in_group("Player"):
		body.speed *= speed_modifier

func _body_exited(body):
	if body.is_in_group("Player"):
		body.speed = normal_speed
