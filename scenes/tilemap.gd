extends TileMap

func _ready():
	SaveManager.register_object(self)
