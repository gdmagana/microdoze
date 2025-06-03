extends Control

var timer: Timer
var ready_to_continue := false
var dissolve_background: Sprite2D

func _ready():
	timer = $Timer  # Make sure this matches your node structure
	setup_dissolve_background()
	start_timer()

func setup_dissolve_background():
	# Get the kitchen background sprite
	dissolve_background = $KitchenWide
	
	# Load the dissolve script
	var dissolve_script = load("res://scripts/DissolveBackground.gd")
	dissolve_background.set_script(dissolve_script)
	
	# Set the textures
	dissolve_background.normal_texture = load("res://assets/narrative/kitchen_wide.png")
	dissolve_background.psychedelic_texture = load("res://assets/narrative/kitchen_trippy.png")
	dissolve_background.dissolve_duration = 3.0
	dissolve_background.auto_start_dissolve = true
	dissolve_background.dissolve_delay = 2.0
	
	# Remove the animated texture and use a single texture
	dissolve_background.texture = dissolve_background.normal_texture

func start_timer():
	timer.start(1.0)  # Duration in seconds
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout():
	ready_to_continue = true

func _input(event):
	if ready_to_continue and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_12.tscn")
