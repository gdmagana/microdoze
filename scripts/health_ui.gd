extends Control

@onready var health_bar: Panel = $HealthBarContainer/HealthBarFrame/HealthBar
@onready var health_frame: Panel = $HealthBarContainer/HealthBarFrame
@onready var progress_background: Panel = $HealthBarContainer/ProgressBarBackground

var low_health_tween: Tween
var rainbow_tween: Tween
var current_health_percentage: float = 1.0

func _ready():
	print("DEBUG: HealthUI _ready called")
	
	# Set up the health bar frame with a border
	if health_frame:
		health_frame.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0)) # Dark gray frame
		print("DEBUG: Health frame setup complete")
	else:
		print("ERROR: Health frame not found!")
	
	# Set up the health bar - start with rainbow effect
	if health_bar:
		health_bar.visible = true
		start_rainbow_effect() # Start with rainbow by default
		print("DEBUG: Health bar setup complete")
		print("DEBUG: Health bar visible: ", health_bar.visible)
	else:
		print("ERROR: Health bar not found!")
		
	print("DEBUG: HealthUI _ready completed")

func start_rainbow_effect():
	print("DEBUG: Starting rainbow effect for health bar")
	
	# Stop any existing effects
	if rainbow_tween:
		rainbow_tween.kill()
	if low_health_tween:
		low_health_tween.kill()
		low_health_tween = null
	
	# Create rainbow animation
	rainbow_tween = create_tween()
	rainbow_tween.set_loops() # Loop infinitely
	
	# Rainbow colors - bright and vibrant
	var rainbow_colors = [
		Color(1.0, 0.0, 0.0, 1.0), # Red
		Color(1.0, 0.5, 0.0, 1.0), # Orange
		Color(1.0, 1.0, 0.0, 1.0), # Yellow
		Color(0.0, 1.0, 0.0, 1.0), # Green
		Color(0.0, 1.0, 1.0, 1.0), # Cyan
		Color(0.0, 0.0, 1.0, 1.0), # Blue
		Color(0.5, 0.0, 1.0, 1.0), # Purple
		Color(1.0, 0.0, 1.0, 1.0) # Magenta
	]
	
	# Cycle through rainbow colors
	for color in rainbow_colors:
		rainbow_tween.tween_method(set_health_bar_color, health_bar.modulate, color, 0.3)
	
	print("DEBUG: Rainbow tween created and started")

func set_health_bar_color(color: Color):
	if health_bar:
		health_bar.add_theme_color_override("bg_color", color)
		health_bar.modulate = Color(1, 1, 1, 1) # Ensure full visibility

func stop_rainbow_effect():
	print("DEBUG: Stopping rainbow effect")
	if rainbow_tween:
		rainbow_tween.kill()
		rainbow_tween = null

func update_health(current_health: float, max_health: float = 100.0):
	print("DEBUG: update_health called with ", current_health, "/", max_health)
	
	if not health_bar:
		print("ERROR: health_bar is null in update_health!")
		return
		
	# Calculate health percentage
	var health_percentage = clamp(current_health / max_health, 0.0, 1.0)
	current_health_percentage = health_percentage
	print("DEBUG: Health percentage: ", health_percentage)
	
	# Update the health bar width by adjusting the anchor
	health_bar.anchor_right = health_percentage
	print("DEBUG: Set anchor_right to: ", health_percentage)
	
	# Add color effects based on health level
	if health_percentage > 0.6:
		# High health - rainbow effect
		print("DEBUG: Set high health colors (rainbow)")
		start_rainbow_effect()
	elif health_percentage > 0.3:
		# Medium health - yellow/orange
		stop_rainbow_effect()
		health_bar.add_theme_color_override("bg_color", Color(1.0, 0.8, 0.0, 1.0))
		health_bar.modulate = Color(1, 1, 1, 1)
		print("DEBUG: Set medium health colors (yellow)")
	else:
		# Low health - red and pulsing effect
		stop_rainbow_effect()
		health_bar.add_theme_color_override("bg_color", Color(1.0, 0.0, 0.0, 1.0))
		health_bar.modulate = Color(1, 1, 1, 1)
		print("DEBUG: Set low health colors (red)")
		if health_percentage > 0:
			start_low_health_pulse()

func start_low_health_pulse():
	# Create a pulsing effect for low health
	if low_health_tween:
		low_health_tween.kill()
	
	low_health_tween = create_tween()
	low_health_tween.set_loops()
	low_health_tween.tween_property(health_bar, "modulate:a", 0.6, 0.5)
	low_health_tween.tween_property(health_bar, "modulate:a", 1.0, 0.5)
