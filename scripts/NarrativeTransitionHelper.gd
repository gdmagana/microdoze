extends Node
class_name NarrativeTransitionHelper

enum TransitionType {
	SIMPLE_CROSSFADE,
	ADVANCED_DISSOLVE
}

static func create_background_transition(
	parent_node: Control,
	normal_texture: Texture2D,
	psychedelic_texture: Texture2D,
	transition_type: TransitionType = TransitionType.SIMPLE_CROSSFADE,
	duration: float = 2.0,
	auto_start: bool = true,
	delay: float = 1.0
) -> Control:
	
	var transition_node: Control
	
	match transition_type:
		TransitionType.SIMPLE_CROSSFADE:
			var dissolve_script = load("res://scripts/DissolveTransition.gd")
			transition_node = dissolve_script.new()
		TransitionType.ADVANCED_DISSOLVE:
			var advanced_script = load("res://scripts/AdvancedDissolveTransition.gd")
			transition_node = advanced_script.new()
	
	# Set common properties
	transition_node.normal_texture = normal_texture
	transition_node.psychedelic_texture = psychedelic_texture
	transition_node.transition_duration = duration
	transition_node.auto_start = auto_start
	transition_node.start_delay = delay
	
	# Add to parent and move to back
	parent_node.add_child(transition_node)
	parent_node.move_child(transition_node, 0)
	
	return transition_node

static func hide_existing_background(parent_node: Control, background_node_name: String):
	"""Helper function to hide existing animated background sprites"""
	var background_node = parent_node.get_node_or_null(background_node_name)
	if background_node:
		background_node.visible = false
	else:
		print("Warning: Background node '" + background_node_name + "' not found")
