extends Area2D

func _ready():
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func _body_entered(body):
	if body.is_in_group("Player"):
		body.speed = 100

func _body_exited(body):
	if body.is_in_group("Player"):
		body.speed = 65
