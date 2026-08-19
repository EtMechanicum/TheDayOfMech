extends Control

const report = preload("res://scenes/text_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ok_button_pressed():
	var report = get_node("TextBox")
	report.queue_free()

func _on_reveneus_pressed() -> void:
	var report = report.instantiate()
	var container = report.get_node("MarginContainer/MarginContainer/VBoxContainer")
	var revenue_text = "Total revenue since last time: %d"%[GameManager.revenue]
	var revenue_label = Label.new()
	revenue_label.text = revenue_text
	container.add_child(revenue_label)
	var went_away_text = "Customers went away: %d"%[GameManager.went_away_count]
	var went_away_label = Label.new()
	went_away_label.text = went_away_text
	container.add_child(went_away_label)
	#OK button
	var ok_button = Button.new()
	ok_button.pressed.connect(_on_ok_button_pressed)
	ok_button.text = "OK"
	ok_button.add_theme_font_size_override("font_size", 48)
	container.add_child(ok_button)
	add_child(report)
	GameManager.player_money += GameManager.revenue
