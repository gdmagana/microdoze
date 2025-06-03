extends Control

var timer: Timer
var ready_to_continue := false

func _ready():
	timer = $Timer  # Make sure this matches your node structure
	start_timer()
	
	# Switch to Heavy bus for scene 13
	switch_to_heavy_bus()

func switch_to_heavy_bus():
	# Access the autoload using get_node
	var audio_manager = get_node("/root/NarrativeAudioManager")
	if audio_manager:
		audio_manager.switch_to_heavy_bus()
	else:
		print("Warning: NarrativeAudioManager not found")

func start_timer():
	timer.start(1.0)  # Duration in seconds
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout():
	ready_to_continue = true

func _input(event):
	if ready_to_continue and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_14.tscn")
