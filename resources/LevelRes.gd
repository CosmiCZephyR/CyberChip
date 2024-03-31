extends Resource
class_name LevelResource

@export var player_resource: PlayerRes
# Object : {"property": value}
@export var objects: Dictionary
# tilemap for some reason
var tilemap

func set_player_resouce(r: PlayerRes):
	player_resource = r

func set_tilemap(t: TileMap):
	tilemap = t
