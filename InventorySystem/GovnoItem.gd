class_name GovnoItem
extends StaticBody2D

@onready var inventory: MainInventory = get_parent()

func _on_mouse_entered():
	inventory.get_current_item(self)
