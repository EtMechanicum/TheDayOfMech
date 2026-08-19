extends Node

signal machine_status_open
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Assign constants for the correct working behaviour
	GameManager.inventory_container = $"MachineOptions/TextureRect/MarginContainer/Panel/PlayerInventory"
	GameManager.ice_slot = $"MachineStatus/TextureRect/IceMenu/Panel/HBoxContainer"
	GameManager.world_reference = self
	#GameManager.ice_timer = $"MachineStatus/IceCooldown"
	#GameManager.ice_warning = $"MachineStatus/IceWarning"
	$MainMenu.show()
	$MachineOverview.hide()
	$MachineOptions.hide()
	$Store.hide()
	$MachineStatus.hide()
	$HUD.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _to_machine_options_button() -> void:
	$MachineOptions.show()
	$MachineOverview.hide()
	$Store.hide()

func _back_to_machine_overview_button() -> void:
	$MachineOverview.show()
	$MachineStatus.hide()
	$MachineOptions.hide()
	$Store.hide()

func _to_vending_mechine() -> void:
	$MachineOverview.show()
	$Store.hide()
	$MachineOptions.hide()
	$MachineStatus.hide()
	$Wastelands.hide()
	$Home.hide()

func _to_store_from_machine() -> void:
	$Store.show()
	$Wastelands.hide()
	$MachineOptions.hide()
	$MachineOverview.hide()
	$Home.hide()


func _to_machine_status_pressed() -> void:
	$MachineStatus.show()
	$Store.hide()
	$MachineOverview.hide()
	$Home.hide()
	GameManager.machine_status_inventory()
	machine_status_open.emit()


func _on_play_button_pressed() -> void:
	$MachineOverview.show()
	$HUD.show()
	$MachineOptions.hide()
	$Store.hide()
	$MachineStatus.hide()
	$Home.hide()


func _on_to_home_pressed() -> void:
	$Home.show()
	$Wastelands.hide()
	$MachineOverview.hide()
	$Store.hide()
	$MachineOptions.hide()
	$MachineStatus.hide()


func _on_to_wastelands_button() -> void:
	$Wastelands.show()
	$Home.hide()
	$MachineOptions.hide()
	$MachineOverview.hide()
	$Store.hide()


func _on_save_pressed() -> void:
	GameManager._save()


func _on_load_pressed() -> void:
	GameManager._load()
	$MachineOverview.show()
	$HUD.show()
	$MachineOptions.hide()
	$Store.hide()
	$MachineStatus.hide()
	$Home.hide()
