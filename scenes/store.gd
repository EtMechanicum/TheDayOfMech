extends Control


var inventory = {
	"cola" : preload("res://assets/resources/cola.tres"), 
	"hotdog" : preload("res://assets/resources/hotdog.tres"),
	"ice" : preload("res://assets/resources/ice.tres"),
	"chips" : preload("res://assets/resources/chips.tres"),
	"coffee" : preload("res://assets/resources/coffee.tres"),
	"giant cookie" : preload("res://assets/resources/giant-cookie.tres")
}

var dialogue_container = {
	1 : preload("res://assets/resources/dialogues/dialogue_container/daily_container.tres"),
	2 : "Moody - Not yet implemented",
	3 : "Something Happened - Not yet implemented"
}

var item_text_font = preload("res://assets/fonts/ChiKareGo2.ttf")

var talking = false
var dialogue_box = preload("res://scenes/text_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.modify_prices.connect(_on_game_manager_modify_prices)
	await get_tree().process_frame
	GameManager._set_up_new_day()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_buy_pressed() -> void:
	launch_inventory()

func launch_inventory() -> void:
	for child in $"TextureRect/ShopMenu/MenuTexture/MarginContainer/GridContainer/HBoxContainer".get_children():
		child.queue_free()
	
	for element in inventory:
		var item = inventory[element]
		var slot = Button.new()
		slot.icon = item.sprite
		slot.expand_icon = true
		slot.custom_minimum_size = Vector2(160.0, 160.0)
		var empty_style := StyleBoxEmpty.new()
		slot.add_theme_stylebox_override("normal", empty_style)
		#slot.add_theme_stylebox_override("hover", empty_style)
		slot.add_theme_stylebox_override("pressed", empty_style)
		slot.text = "%s - %d coins"%[item.name, item.shop_price]
		slot.add_theme_font_override("font", item_text_font)
		slot.add_theme_font_size_override("font_size", 24)
		slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		$"TextureRect/ShopMenu/MenuTexture/MarginContainer/GridContainer/HBoxContainer".add_child(slot)
		slot.pressed.connect(_on_product_selected.bind(item))
	$"TextureRect/ShopMenu".show()

func _on_product_selected(item: Resource):
	print("You've selected ", item.name)
	if item.shop_price <= GameManager.player_money:
		GameManager.player_money -= item.shop_price
		GameManager.player_inventory[item] += 1
		print(GameManager.player_inventory[item])
	else:
		print("Not enough money")

func _on_game_manager_modify_prices():
	print("on modify prices new day")
	for item in inventory:
		if(item == "ice"):
			continue
		inventory[item].shop_price = inventory[item].base_shop_price * GameManager.price_change.pick_random()
		print(item, " -> ", inventory[item].shop_price)


func _on_talk_pressed() -> void:
	talking = true
	var dialogue_screen = dialogue_box.instantiate()
	var dialogue_prob = randi_range(1, 10)
	var dialogue
	#Commented implementation makes use of categories in dialogues
	#It is not used for now. Maybe in the future
	#if dialogue_prob <= 7 :
	dialogue = dialogue_container[1].dialogues.pick_random()
	#elif dialogue_prob > 7 && dialogue_prob < 10:
	#	return
	#elif dialogue_prob == 10:
		#return
	#At this point, we have already chosen the dialogue to show
	#var dialogue_window = dialogue_box.instantiate()
	var line_label = dialogue_screen.get_node("MarginContainer/Panel/MarginContainer/VBoxContainer/Label")
	var next_button = dialogue_screen.get_node("MarginContainer/Panel/MarginContainer/VBoxContainer/OkButton")

	add_child(dialogue_screen)
	dialogue_screen.get_node("MarginContainer").position = Vector2(0.0, 920.0)
	for line in dialogue.lines:
		line_label.text = line
		await next_button.pressed

	dialogue_screen.queue_free()
	talking = false


func _on_ok_button_pressed() -> void:
	$"TextureRect/ShopMenu".hide()
