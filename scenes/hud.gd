extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager._money_changed.connect(update_player_money_label)
	update_player_money_label(GameManager.player_money)
	$DayCount.text = "Day " + str(GameManager.day_number)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_player_money_label(money):
	$MarginContainer/MoneyTexture/PlayerMoney.text = "%d"%[money]
