extends Control

#func set_item(value):
#	item_data = value
#	_draw_item()

func _get_drag_data(at_position):
	return pickup_item(at_position)

func pickup_item(at_position):
	var _item_index = 0
	var _item = get_parent().item
	
	if _item is Item:
		var data = {}
		data.item = _item
		data.item_index = _item_index
		
		#HACK:
		data.inventory_res = $"../../".inventory
		
		var _drag_preview = TextureRect.new()
		_drag_preview.texture = _item.texture
		_drag_preview.position = Vector2.ONE
		
		set_drag_preview(_drag_preview)
		
		return data

#func _can_drop_data(at_position, data) -> bool:
#	return can_drop_item(at_position, data)

#func can_drop_item(at_position, data) -> bool:
#	return data is Dictionary and data.has("item")

#func _drop_data(at_position, droped_data) -> void:
#	drop_item(at_position, droped_data)

#func drop_item(at_position, droped_data) -> void:
#	var _local_target_item_index = get_index()
#
#	inventory.swap_items(_local_target_item_index, droped_data)
#	inventory.set_item(_local_target_item_index, droped_data.item)
#
#	var _previous_slot = get_parent().get_child(droped_data.item_index)
