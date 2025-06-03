# Alternative implementation for narrative_11.gd using the helper
extends Control

const NarrativeTransitionHelper = preload("res://scripts/NarrativeTransitionHelper.gd")

var timer: Timer
var ready_to_continue := false
var dissolve_transition: Control

func _ready():
	timer = $Timer
	setup_dissolve_transition_with_helper()
	start_timer()

func setup_dissolve_transition_with_helper():
	# Hide existing background
	NarrativeTransitionHelper.hide_existing_background(self, "KitchenWide")
	
	# Create transition using helper
	dissolve_transition = NarrativeTransitionHelper.create_background_transition(
		self,
		load("res://assets/narrative/kitchen_wide.png"),
		load("res://assets/narrative/kitchen_trippy.png"),
		NarrativeTransitionHelper.TransitionType.SIMPLE_CROSSFADE,  # or ADVANCED_DISSOLVE
		3.0,  # duration
		true, # auto_start
		2.0   # delay
	)

func start_timer():
	timer.start(1.0)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _on_Timer_timeout():
	ready_to_continue = true

func _input(event):
	if ready_to_continue and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_12.tscn")
