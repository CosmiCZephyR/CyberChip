extends Sprite2D

var has_hit: bool = false

func _physics_process(delta):
	position.y += 1

func _on_attack_hit_box_body_entered(body):
	if body.is_in_group("Player"):
		await get_tree().create_timer(0.01).timeout
		queue_free()
	else:
		queue_free()
