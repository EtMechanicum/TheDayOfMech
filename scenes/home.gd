extends Control

const ITEM_SPAWN_PATH = "TextureRect/Inventory/MenuTexture/MarginContainer/GridContainer/HBoxContainer"
const CURRENT_PRICE_LABEL_PATH = "TextureRect/PriceManager/TextureRect/HBoxContainer/CurrentPrice"
var item_being_modified : Resource
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect/Inventory.hide()
	$TextureRect/PriceManager.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_inventory_pressed() -> void:
	spawn_inventory()
	
func spawn_inventory() -> void:
	var inventory = GameManager.player_inventory
	if get_node(ITEM_SPAWN_PATH).get_children() != null:
		for child in get_node(ITEM_SPAWN_PATH).get_children():
			child.queue_free()
	else: 
		return
	
	for element in inventory:
		if inventory[element] > 0: #if item quantity is greater than zero, then show it
			var slot = Button.new()
			slot.icon = element.sprite
			slot.expand_icon = true
			slot.custom_minimum_size = Vector2(160.0, 160.0)
			var empty_style := StyleBoxEmpty.new()
			slot.add_theme_stylebox_override("normal", empty_style)
			#slot.add_theme_stylebox_override("hover", empty_style)
			slot.add_theme_stylebox_override("pressed", empty_style)
			slot.text = "%d coins"%[element.shop_price]
			slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			slot.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			$"TextureRect/Inventory/MenuTexture/MarginContainer/GridContainer/HBoxContainer".add_child(slot)
			slot.pressed.connect(_on_product_selected.bind(element))
	$"TextureRect/Inventory".show()

func _on_product_selected(item: Resource):
	item_being_modified = item
	$TextureRect/PriceManager.show()
	$"TextureRect/PriceManager/TextureRect/HBoxContainer/CurrentPrice".text = str(item.machine_price)


func _on_add_1_pressed() -> void:
	var current_price = get_node(CURRENT_PRICE_LABEL_PATH).text.to_int()
	get_node(CURRENT_PRICE_LABEL_PATH).text = str(current_price + 1)
	


func _on_add_5_pressed() -> void:
	var current_price = get_node(CURRENT_PRICE_LABEL_PATH).text.to_int()
	get_node(CURRENT_PRICE_LABEL_PATH).text = str(current_price + 5)


func _on_sub_5_pressed() -> void:
	var current_price = get_node(CURRENT_PRICE_LABEL_PATH).text.to_int()
	if current_price - 5 < 0:
		get_node(CURRENT_PRICE_LABEL_PATH).text = "0"
	else:
		get_node(CURRENT_PRICE_LABEL_PATH).text = str(current_price - 5)


func _on_sub_1_pressed() -> void:
	var current_price = get_node(CURRENT_PRICE_LABEL_PATH).text.to_int()
	if current_price - 1 < 0:
		get_node(CURRENT_PRICE_LABEL_PATH).text = "0"
	else:
		get_node(CURRENT_PRICE_LABEL_PATH).text = str(current_price - 1)


func _on_price_manager_ok_button_pressed() -> void:
	update_item_price()
	$"TextureRect/PriceManager".hide()

func update_item_price() -> void:
	item_being_modified.machine_price = get_node(CURRENT_PRICE_LABEL_PATH).text.to_int()


func _on_close_inventory_button_pressed() -> void:
	$"TextureRect/Inventory".hide()
