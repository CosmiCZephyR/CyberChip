extends Sprite2D

var has_hit: bool = false

func _physics_process(delta):
	position.y += 1

func _on_attack_hit_box_body_entered(body):
	if body.is_in_group("Player") and not has_hit:
		has_hit = true
		await get_tree().create_timer(0.0001).timeout
		self.queue_free()
	else:
		self.queue_free()
	
#	print_debug(has_hit)
