extends Node

var world_reference: Node

### PLAYER STUFF ###
var player_money: float = 40:
	set(value):
		player_money = value
		_money_changed.emit(player_money)

#Dictionary resource to quantity
var player_inventory = {
	preload("res://assets/resources/cola.tres") : 1,
	#preload("res://assets/resources/hotdog.tres") : 0,
	preload("res://assets/resources/ice.tres") : 0,
	preload("res://assets/resources/chips.tres") : 0
}

###VENDING MACHINE STUFF###

var machine_inventory = {
	preload("res://assets/resources/cola.tres") : 0,
	#preload("res://assets/resources/hotdog.tres") : 0
	preload("res://assets/resources/chips.tres") : 0
}

var inventory_container: HBoxContainer:
	set(container):
		inventory_container = container

var ice_slot: HBoxContainer:
	set(container):
		ice_slot = container

var ice_timer: Timer
var ice_warning: Timer

const INVENTORY_SLOT = preload("res://scenes/prototypes/slot.tscn")
const ICE_EFFECT_TIME = 1800.0 #seconds - 3600: one hour
const ICE_WARNING = ICE_EFFECT_TIME/2

signal _money_changed(new_amount: int)

var customer_timer
var day_timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	#cooldown timer
	ice_timer = Timer.new()
	ice_timer.wait_time = ICE_EFFECT_TIME
	ice_timer.one_shot = true
	add_child(ice_timer)
	ice_timer.timeout.connect(_on_ice_cooldown_timeout)
	#warning timer
	ice_warning = Timer.new()
	ice_warning.wait_time = ICE_WARNING
	ice_warning.one_shot = true
	add_child(ice_warning)
	ice_warning.timeout.connect(_on_ice_warning_timeout)
	#ice timer start
	ice_timer.start()
	ice_warning.start()
	#customer timer
	customer_timer = Timer.new()
	customer_timer.wait_time = randi_range(0, 600) #two seconds - two minutes for now
	add_child(customer_timer)
	customer_timer.timeout.connect(_on_customer_timer_timeout)
	customer_timer.start()
	#day timer
	day_timer = Timer.new()
	day_timer.wait_time = 120 #one day = two minutes for test purposes only
	day_timer.one_shot = true
	add_child(day_timer)
	day_timer.timeout.connect(_set_up_new_day)
	#_set_up_new_day()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
###For the button version of the player's inventory
func inventory_update():
	for child in inventory_container.get_children():
		child.queue_free()
	
	for element in GameManager.player_inventory:
		var quantity = GameManager.player_inventory[element]
		var slot = Button.new()
		slot.icon = element.sprite
		slot.text = "x %d" % [quantity]
		slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_icon_alignment = VERTICAL_ALIGNMENT_BOTTOM
		inventory_container.add_child(slot)
		
###Draggable version of player's inventory (restock only)
func inventory_restock():
	for child in inventory_container.get_children():
		child.queue_free()
	for item in player_inventory:
		var quantity = player_inventory[item]
		if quantity <= 0 || item.name == "ice":
			continue
		var slot = INVENTORY_SLOT.instantiate()
		slot.item_type = item
		slot.texture = item.sprite
		slot.size = Vector2(250, 250)
		inventory_container.add_child(slot)

### MACHINE STATUS SECTION ###

var revenue = 0
#Comunicates to MachineStatus that a new ice load has been placed in the cooler device
var machine_broken = false
var broken_fuses: int
const FUSE_COST = 25
signal ice_renewed #ice has been loaded in the machine
signal ice_cooldown #if it goes to zero, the machine breaks
signal ice_warning_timeout #if goes to zero, the machine launches a warning

func machine_status_inventory():
	for child in inventory_container.get_children():
		child.queue_free()
	for item in player_inventory:
		var quantity = player_inventory[item]
		if item.name == "ice" && quantity > 0:
			var slot = INVENTORY_SLOT.instantiate()
			slot.item_type = item
			slot.texture = item.sprite
			slot.size = Vector2(250, 250)
			ice_slot.add_child(slot)

func start_ice_cooldown():
	ice_timer.stop()
	ice_warning.stop()
	ice_warning.start()
	ice_timer.start()
	machine_broken = false
	print("machine_broken <- false (start_ice_cooldown)")
	ice_renewed.emit()
	print("timer set")


func _on_ice_cooldown_timeout() -> void:
	print("timeout?")
	ice_cooldown.emit()

func _on_ice_warning_timeout() -> void:
	ice_warning_timeout.emit()
	
### DAYS STUFF ###
#wheater, price changes per product
var day_number = 1
var weather_types = ["sunny", "rainy", "cold"]
var weather = {
	"sunny" : preload("res://assets/sprites/weather/sunny.png"),
	"rainy" : preload("res://assets/sprites/weather/rainy-day.png"),
	"cold" : preload("res://assets/sprites/weather/cloudy-day.png")
}
#multiply them for the item shop prices
var price_change = [1.05, 1.0, 0.95, 1.10, 1.0, 0.90, 1.0, 1.15, 0.85]
var today_weather : String
#var today_prices = price_change.pick_random()
signal modify_prices

func _set_up_new_day():
	today_weather = weather_types.pick_random()
	world_reference.get_node("HUD/WeatherIcon/WeatherTexture").texture = weather[today_weather]
	modify_prices.emit()
	day_timer.start()
	day_number += 1
	print("new day")

func _on_day_timer_timeout():
	_set_up_new_day()

### Customers Section ###
var customers = {
	1 : preload("res://assets/resources/customers/boiz.tres"),
	2 : preload("res://assets/resources/customers/adulz.tres"),
	3 : preload("res://assets/resources/customers/richz.tres")
}

var went_away_count = 0
signal item_purched
signal spawn_visible_customer(customer: CustomerResource)
signal despawn_customer

func _on_customer_timer_timeout() -> void:
	#generate customer type
	var customer = customers[randi_range(1, 3)]
	while !customer.spawn_days.has(GameManager.today_weather):
		customer = customers[randi_range(1, 3)]
	#var item_chosen = customer_picks_item(customer) #per ora non fa nulla
	spawn_visible_customer.emit(customer)
	var customer_thinking = Timer.new()
	customer_thinking.wait_time = 10.0
	customer_thinking.one_shot = true
	customer_thinking.timeout.connect(customer_picks_item.bind(customer, customer_thinking))
	world_reference.add_child(customer_thinking)
	customer_thinking.start()


func customer_picks_item(customer: CustomerResource, customer_thinking: Timer) -> void:
	customer_thinking.queue_free()
	if machine_broken:
		print("A %s finds the machine broken." % customer.name)
		went_away_count += 1
		despawn_customer.emit()
		return
	var available_items := []
	for item in machine_inventory:
		if machine_inventory[item] > 0 and customer.favorites == item.category:
			available_items.append(item)
	if available_items.is_empty():
		print("A %s finds a cosmic nothing." % customer.name)
		went_away_count += 1
		despawn_customer.emit()
		return
	var chosen = available_items.pick_random()
	print("quantity pre customer:", machine_inventory[chosen])
	machine_inventory[chosen] -= 1
	print("quantity post customer:", machine_inventory[chosen])
	revenue += chosen.machine_price
	item_purched.emit(chosen)
	despawn_customer.emit()

### Save And Load ###
const SAVE_PATH: String = "user://save.json"
var save_data: Dictionary = {
	#player stuff
	"player_money" : 0,
	"player_inventory" : null,
	#machine stuff
	"machine_inventory" : null,
	"revenue" : 0,
	"cooldown_time_left" : 0,
	"warning_time_left" : 0,
	#machine status
	"machine_broken" : false,
	"broken_fuses" : 0,
	#day stuff
	"day_number" : 0
}

func _save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	save_data["player_money"] = player_money
	save_data["player_inventory"] = player_inventory
	save_data["machine_inventory"] = machine_inventory
	save_data["revenue"] = revenue
	save_data["cooldown_time_left"] = ice_timer.time_left
	save_data["warning_time_left"] = ice_warning.time_left
	save_data["machine_broken"] = machine_broken
	save_data["broken_fuses"] = broken_fuses
	save_data["day_number"] = day_number + 1
	
	file.store_var(save_data)
	file.close()

func _load() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data: Dictionary = file.get_var()
		for i in data:
			if save_data.has(i):
				save_data[i] = data[i]
			file.close()
		#player stuff
		player_money = save_data["player_money"]
		player_inventory = save_data["player_inventory"]
		#day
		day_number = save_data["day_number"]
		#machine stuff
		machine_inventory = save_data["machine_inventory"]
		revenue = save_data["revenue"]
		machine_broken = save_data["machine_broken"]
		broken_fuses = save_data["broken_fuses"]
		if broken_fuses > 0:
			ice_cooldown.emit()
		#timers
		if save_data["warning_time_left"] > 0:
			ice_warning.stop()
			ice_warning.start(save_data["warning_time_left"])
		if save_data["cooldown_time_left"] > 0:
			ice_timer.stop()
			ice_timer.start(save_data["cooldown_time_left"])
