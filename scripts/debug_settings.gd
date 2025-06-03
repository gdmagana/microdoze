extends Node

# Debug Settings Singleton
# Add this to AutoLoad in Project Settings for easy access

# Narrative settings
@export var skip_narrative_intro := false # Set to true to skip intro for debugging

# Other debug settings can be added here
@export var enable_powerup_debug_ui := true
@export var show_debug_logs := true

func _ready():
	print("  Skip narrative intro: ", skip_narrative_intro)
	print("  Powerup debug UI: ", enable_powerup_debug_ui)
	print("  Debug logs: ", show_debug_logs)

func _input(event):
	# F10 to go directly to game from anywhere (debug)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

# Quick function to toggle narrative intro skipping
func toggle_narrative_skip():
	skip_narrative_intro = !skip_narrative_intro

# Function to log debug messages only if enabled
func debug_log(message: String):
	if show_debug_logs:
		print("DEBUG: ", message)