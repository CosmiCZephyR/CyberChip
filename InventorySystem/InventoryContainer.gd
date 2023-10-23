class_name InventoryContainer
extends Node2D

var items: Array

func add_item(_item: Item):
	items.append(_item)

func remove_item(_item: Item):
	items.erase(_item)
	pass
