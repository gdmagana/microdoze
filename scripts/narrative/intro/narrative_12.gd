extends Control

var timer: Timer
var ready_to_continue := false
var dissolve_transition: Control

func _ready():
	timer = $Timer  # Make sure this matches your node structure
	setup_dissolve_transition()
	start_timer()

func setup_dissolve_transition():
	# Hide the existing animated texture sprite
	var kitchen_sprite = $Sprite2D
	kitchen_sprite.visible = false
	
	# Create dissolve transition
	var dissolve_script = load("res://scripts/DissolveTransition.gd")
	dissolve_transition = dissolve_script.new()
	
	# Set textures
	dissolve_transition.normal_texture = load("res://assets/narrative/kitchen_wide.png")
	dissolve_transition.psychedelic_texture = load("res://assets/narrative/kitchen_trippy.png")
	dissolve_transition.transition_duration = 4.0
	dissolve_transition.auto_start = true
	dissolve_transition.start_delay = 1.5
	
	# Add it to the scene (insert before character so it's behind)
	add_child(dissolve_transition)
	move_child(dissolve_transition, 0)  # Move to back

func start_timer():
	timer.start(1.0)  # Duration in seconds
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout():
	ready_to_continue = true

func _input(event):
	if ready_to_continue and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_13.tscn")
