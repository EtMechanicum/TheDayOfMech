extends Control

var no_ice = {
	1 : preload("res://assets/sprites/cooling_broken1.png"),
	2 : preload("res://assets/sprites/cooling_broken2.png"),
	3 : preload("res://assets/sprites/cooling_broken3.png"),
	4 : preload("res://assets/sprites/cooling_broken4.png")
}
var half_ice = preload("res://assets/sprites/cooling_half.png")
var full_ice = preload("res://assets/sprites/cooling.png")

var broken_fuses_screen = preload("res://scenes/text_box.tscn")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ice_renewed.connect(_on_game_manager_ice_renewed)
	GameManager.ice_cooldown.connect(_on_game_manager_ice_cooldown)
	GameManager.ice_warning_timeout.connect(_on_game_manager_ice_warning)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Removes the exture from the cooler device.
#Also triggers the breaking of fuses


func _on_game_manager_ice_renewed() -> void:
	$TextureRect.texture = full_ice
	print("In Machine Status - ice renewed")

func _on_game_manager_ice_cooldown() -> void:
	print("In Machine Status - ice cooldown")
	#$"TextureRect/Led".texture = red_led
	$"TextureRect/IceContainer/DeviceOpening".texture = null
	GameManager.machine_broken = true
	GameManager.broken_fuses = randi_range(1, 4)
	$TextureRect.texture = no_ice[GameManager.broken_fuses]
	print("machine_broken <- true (_on_game_manager_ice_cooldown)")
	#pay to fix
	var fuses_payment = broken_fuses_screen.instantiate()
	var current_line = fuses_payment.get_node("MarginContainer/Panel/MarginContainer/VBoxContainer/Label")
	var fix_text1 = "The vending machine has been damaged from overheat."
	var fix_text2 = "There are %d broken fuses."%[GameManager.broken_fuses]
	var fix_cost = GameManager.FUSE_COST * GameManager.broken_fuses
	var fix_cost_text = "Pay %d coins to fix."%[fix_cost]
	var dialogues : Array[String]
	dialogues.append(fix_text1)
	dialogues.append(fix_text2)
	var next_button = fuses_payment.get_node("MarginContainer/Panel/MarginContainer/VBoxContainer/OkButton")
	#Per come funziona ora, la schermata di pagamento viene visualizzata anche se il giocatore non si trova
	#nella schermata MachineStatus.
	#TO DO: creare segnale "machine status open" e aspettare il segnale per aggiungere il figlio alla scena
	await get_parent().machine_status_open
	add_child(fuses_payment)
	
	
	for line in dialogues:
		current_line.text = line
		await next_button.pressed
	current_line.text = fix_cost_text
	next_button.pressed.connect(_on_pay_button_pressed.bind(fix_cost))

func _on_pay_button_pressed(fix_cost: int):
	GameManager.player_money -= fix_cost
	var payment_screen = get_node("TextBox")
	$"TextureRect".texture = full_ice
	GameManager.start_ice_cooldown()
	payment_screen.queue_free()


func _on_game_manager_ice_warning() -> void:
	print("In Machine Status - ice warning")
	$TextureRect.texture = half_ice
