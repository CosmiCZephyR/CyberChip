extends Control

# I think, that signals are need here
signal item_dragged
signal data_dropped

## Wrapper-method for item pickup
func _get_drag_data(at_position) -> Variant:
	emit_signal("item_dragged")
	return pickup_item(at_position)

## This method create data dictionary
@warning_ignore("unused_parameter")
func pickup_item(at_position):
	var _item_index = 0
	var _item = get_parent().item
	
	if _item is Item:
		var data = {} as Dictionary
		
		data.item = _item
		data.item_index = _item_index
		data.item_scene = _item.source_scene
		
		data.inventory_res = get_parent().tile_items_container.inventory
		
		var _drag_preview = TextureRect.new()
		_drag_preview.texture = _item.texture
		
		set_drag_preview(_drag_preview)
		
		return data

## Wrapper-method for checking data
func _can_drop_data(at_position, data) -> bool:
	return can_drop_item(at_position, data)

## Checks the data: whether it is a dictionary and whether it contains the item
@warning_ignore("unused_parameter")
func can_drop_item(at_position, data) -> bool:
	return data is Dictionary and data.has("item")
