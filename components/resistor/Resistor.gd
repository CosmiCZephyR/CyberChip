extends Area2D

var flag := false

func _ready():
	self.body_entered.connect(self._body_entered)
	self.body_exited.connect(self._body_exited)

func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body.is_in_group("Player") and not flag:
			body.current_kosuki = body.current_kosuki / 2
			flag = true

func _body_entered(body):
	if body.is_in_group("Player"):
		body.speed = 32.5

func _body_exited(body):
	if body.is_in_group("Player"):
		body.speed = 65
