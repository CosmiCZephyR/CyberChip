extends Node

class_name Magnetism

var magnetic_objects: Array
var collision_shape: CollisionShape2D
var direction: Vector2
var object_rect: Rect2
var shape: Shape2D
var extents

@warning_ignore("shadowed_variable_base_class")
func activate(player_rect: Rect2, master: Node, delta: float) -> void:
	magnetic_objects = get_magnetic_objects()
	for object in magnetic_objects:
		collision_shape = object.get_node("CollisionShape2D")
		shape = collision_shape.shape
		extents = shape.extents
		object_rect = Rect2(object.global_position - extents, extents * 2)
		if player_rect.intersects(object_rect):
			continue
		direction = (master.global_position - object.global_position).normalized()
		object.move_and_collide(direction * 100)

func get_magnetic_objects():
	magnetic_objects = []
	magnetic_objects = get_tree().get_nodes_in_group("magnetic")
	return magnetic_objects
