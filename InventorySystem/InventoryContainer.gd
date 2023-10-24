class_name InventoryContainer
extends Node2D

var items: Array

func add_item(_item: Item):
	items.append(_item)

func remove_item(_item: Item):
	items.erase(_item)
	pass

#func  _ready():
#	var _res1 = load("res://InventorySystem/Resouces/Inventory.tres").duplicate_r(true)
#	var _res2 = load("res://InventorySystem/Resouces/Inventory.tres").duplicate_r(true)
#
#	prints(_res1, _res2)
