extends TextureRect

@onready var element_texture = $HealthBarElementTexture

@export var color: Color = Color(0, 0, 0, 0)

var active: bool = true

func _ready():
	element_texture.modulate = color
