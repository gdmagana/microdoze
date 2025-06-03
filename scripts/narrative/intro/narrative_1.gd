extends Control

var timer : Timer
var ready_to_continue := false

func _ready():
	timer = $Timer  # Adjust the path if needed
	start_timer()

func start_timer():
	timer.start(1.0)  # Set desired delay
	timer.connect("timeout", _on_Timer_timeout)

func _on_Timer_timeout():
	ready_to_continue = true

func _input(event):
	if ready_to_continue and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_2.tscn")
