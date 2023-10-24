extends Node

class_name Magnetism

var magnetic_objects: Array
var collision_shape: CollisionShape2D
var direction: Vector2
var object_rect: Rect2
var shape: Shape2D
var extents

func activate(player_rect: Rect2, master: Node, delta: float) -> void:
	magnetic_objects = _get_magnetic_objects()
	for object in magnetic_objects:
		if not _is_intersecting_with_player(object, player_rect):
			_move_object_towards_master(object, master, delta)

func _is_intersecting_with_player(object: Node, player_rect: Rect2) -> bool:
	collision_shape = object.get_node("CollisionShape2D")
	shape = collision_shape.shape
	extents = shape.extents
	object_rect = Rect2(object.global_position - extents, extents * 2)
	
	return player_rect.intersects(object_rect)

func _move_object_towards_master(object: Node, master: Node, delta: float) -> void:
	direction = (master.global_position - object.global_position).normalized()
	object.move_and_collide(direction * 100 * delta)

func _get_magnetic_objects() -> Array:
	magnetic_objects = get_tree().get_nodes_in_group("magnetic")
	return magnetic_objects
