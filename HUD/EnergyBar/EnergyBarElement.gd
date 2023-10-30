extends TextureRect

@onready var element_texture: TextureRect = $EnergyBarElementTexture

@export var color: Color = Color(0, 0, 0, 1)

func _ready():
	element_texture.modulate = color
