extends Node

class_name Magnetism

@warning_ignore("shadowed_variable_base_class")
func activate(player_rect: Rect2, delta: float, master) -> void:
	var magnetic_objects = get_magnetic_objects()
	for obj in magnetic_objects:
		var collision_shape = obj.get_node("CollisionShape2D")
		var shape = collision_shape.shape
		var extents = shape.extents
		var obj_rect = Rect2(obj.global_position - extents, extents * 2)
		if player_rect.intersects(obj_rect):
			continue
		var direction = (master.global_position - obj.global_position).normalized()
		obj.move_and_collide(direction * 100 * delta)

func get_magnetic_objects():
	var magnetic_objects = []
	magnetic_objects = get_tree().get_nodes_in_group("magnetic")
	return magnetic_objects
