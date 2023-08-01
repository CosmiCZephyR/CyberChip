extends Area2D

class_name EnergySource

var layer = 1
var stop_layer = 2

@onready var _tilemap = get_parent()

var glowing_tiles_count = 0

func _process(delta):
	find_tiles()

# вызываем на заранее свободной клетке
func fool_fill(pos: Vector2i):
#	закрашиваем
#	если сосед свободен
#		fool_fill(pos соседа)
	pass

func find_tiles():
	for x in range(_tilemap.get_used_rect().size.x):
		for y in range(_tilemap.get_used_rect().size.y):
			var tile_pos = Vector2(x, y)
			if _tilemap.get_cell_source_id(stop_layer, tile_pos) != -1:
				return # остановиться, если тайл на слое 2
			if _tilemap.get_cell_source_id(layer, tile_pos) != -1:
				glowing_tiles_count += 1
				print_debug(glowing_tiles_count)
