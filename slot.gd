extends TextureRect

var item_type: ItemResource

func _get_drag_data(at_position: Vector2) -> Variant:
	if texture == null:
		return 
	var preview = duplicate()
	var c = Control.new()
	c.add_child(preview)
	preview.position -= Vector2(125, 125)
	set_drag_preview(c)
	return self
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is TextureRect
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	#Take off the item dropped from the player's inventory
	var item_source = data.item_type
	var item_quantity_in_player = GameManager.player_inventory[item_source]
	GameManager.player_inventory[item_source] -= 1
	print("remaining items: %d"%[item_quantity_in_player])
	#Update inventory slot texture 
	texture = data.texture
	if item_source.name == "ice":
		GameManager.machine_status_inventory()
		GameManager.start_ice_cooldown()
		return
	#vending machine inventory update
	var items_in_machine = GameManager.machine_inventory[item_source]
	print("Items quantity before updating: %d"%[items_in_machine])
	GameManager.machine_inventory[item_source] += 1
	items_in_machine = GameManager.machine_inventory[item_source]
	print("Item quantity after updating:  %d"%[items_in_machine])
	GameManager.inventory_restock()
#signal _on_item_dropped_on_machine()
