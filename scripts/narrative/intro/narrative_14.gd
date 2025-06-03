extends Control

var timer: Timer
var ready_to_continue := false
var dissolve_transition: Control

func _ready():
	timer = $Timer  # Make sure this matches your node structure
	setup_dissolve_transition()
	start_timer()
	
	# Switch to Heavy bus for scene 13
	switch_to_heavy_bus()

func setup_dissolve_transition():
	# Hide the existing animated texture sprite
	var kitchen_sprite = $KitchenWide
	kitchen_sprite.visible = false
	
	# Create dissolve transition
	var dissolve_script = load("res://scripts/DissolveTransition.gd")
	dissolve_transition = dissolve_script.new()
	
	# Set textures
	dissolve_transition.normal_texture = load("res://assets/narrative/kitchen_zoomed.png")
	dissolve_transition.psychedelic_texture = load("res://assets/narrative/kitchen_zoomed_trippy.png")
	dissolve_transition.transition_duration = 2.5
	dissolve_transition.auto_start = true
	dissolve_transition.start_delay = 0.5
	
	# Add it to the scene (insert before character so it's behind)
	add_child(dissolve_transition)
	move_child(dissolve_transition, 0)  # Move to back

func switch_to_heavy_bus():
	# Access the autoload using get_node to switch to Heavy bus
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
		get_tree().change_scene_to_file("res://scenes/levels/level0.tscn")
