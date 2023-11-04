class_name BaseTile
extends Node

@export_category("Tile Properties")
@export var position: Vector2i = Vector2i(0, 0)
@export var size: Vector2i = Vector2i(16, 16)
@export var texture: AtlasTexture

var neighbors_4: Array[Vector2i]: get = get_neghbors_4
var neighbors_8: Array[Vector2i]: get = get_neighbors_8

func get_neghbors_4():
	pass

func get_neighbors_8():
	pass
