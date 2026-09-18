extends Control

var current_event : Resource
var event_available : bool

var default_backgrounds = {
	"default_day" : preload("res://assets/sprites/wastelands.png"),
	"default_night" : preload("res://assets/sprites/wastelands-night.png")
}

var default_track = preload("res://assets/audio/songs/tdom_song_0.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.event_available.connect(_show_event_available)
	$"TextureRect/Buttons/HBoxContainer/Event?".disabled = true
	$"TextureRect/DialogueContainer".hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _show_event_available(event : Resource):
	print("segnale evento emesso")
	current_event = event
	event_available = true
	$"TextureRect/Buttons/HBoxContainer/Event?".disabled = false

func _on_event_pressed() -> void:
	_run_event()

func _run_event():
	var line_window = $"TextureRect/DialogueContainer/Panel/MarginContainer/Panel/MarginContainer/DialogueLine"
	var event_button = $"TextureRect/DialogueContainer/Panel/MarginContainer/Panel/NextLine"
	$"TextureRect/Buttons/HBoxContainer/ToHome".disabled = true
	$"TextureRect/Buttons/HBoxContainer/ToStore".disabled = true
	$"TextureRect/Buttons/HBoxContainer/Event?".disabled = true
	$"TextureRect".texture = current_event.background
	$"TextureRect/DialogueContainer".show()
	GameManager.day_timer.stop()
	var audioplayer = get_parent().get_node("AudioStreamPlayer")
	audioplayer.stream = current_event.ost
	audioplayer.play()
	for line in current_event.dialogues:
		line_window.text = line
		await event_button.pressed
	$"TextureRect/DialogueContainer".hide()
	#finiti i dialoghi
	audioplayer.stream = default_track
	audioplayer.play()
	event_button.disabled = true
	$"TextureRect/Buttons/HBoxContainer/ToHome".disabled = false
	$"TextureRect/Buttons/HBoxContainer/ToStore".disabled = false
	#dovrei aggiungere una sorta di transizione tra eventi e momenti normali. Altrimenti e' troppo brusco
	#quando finisce un evento, finisce il giorno/notte
	if GameManager.day_time == "day":
		$"TextureRect".texture = default_backgrounds["default_day"]
	else:
		$"TextureRect".texture = default_backgrounds["default_night"]
	if GameManager.today_weather == "rainy":
		$"TextureRect/Rain".show()
		$"TextureRect/Rain".play()
	current_event.available = false
	current_event.launched_once = true
	GameManager.day_timer.paused = false
