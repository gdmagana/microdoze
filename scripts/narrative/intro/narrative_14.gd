extends Control

var dissolve_transition: Control

func _ready():
	setup_dissolve_transition()

func setup_dissolve_transition():
	# Hide the existing animated texture sprite
	var kitchen_sprite = $KitchenWide
	kitchen_sprite.visible = false
	
	# Create dissolve transition
	var dissolve_script = load("res://scripts/DissolveTransition.gd")
	dissolve_transition = dissolve_script.new()
	
	# Set textures - using zoomed versions for scene 14
	dissolve_transition.normal_texture = load("res://assets/narrative/kitchen_zoomed.png")
	dissolve_transition.psychedelic_texture = load("res://assets/narrative/kitchen_zoomed_trippy.png")
	dissolve_transition.transition_duration = 2.0
	dissolve_transition.auto_start = true
	dissolve_transition.start_delay = 0.2
	
	# Add it to the scene (insert before other elements so it's behind)
	add_child(dissolve_transition)
	move_child(dissolve_transition, 0)  # Move to back

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Level0.tscn")
