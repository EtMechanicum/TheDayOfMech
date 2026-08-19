extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.item_purched.connect(_on_item_purchased)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restock_pressed() -> void:
	GameManager.inventory_restock()

func _on_item_purchased(item_purchased: ItemResource):
	for slot in $TextureRect/GridContainer.get_children():
		if(slot.texture == item_purchased.sprite):
			#For now it simply removes the texture
			slot.texture = null
			return
