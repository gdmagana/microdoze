extends Control

@onready var health_bar: ColorRect = $HealthBarContainer/HealthBarFrame/HealthBar
@onready var health_frame: Panel = $HealthBarContainer/HealthBarFrame
@onready var progress_background: Panel = $HealthBarContainer/ProgressBarBackground

var low_health_tween: Tween
var rainbow_tween: Tween
var current_health_percentage: float = 1.0

# Shader effect variables - CUSTOMIZE THESE FOR DIFFERENT EFFECTS
var rainbow_scroll_speed := 1.0 # How fast the rainbow scrolls (higher = faster)
var wiggle_intensity := 0.3 # How much the rainbow wiggles (0.0 = no wiggle, 1.0 = intense)
var wiggle_frequency := 8.0 # How many wiggle waves across the bar (higher = more waves)
var rainbow_intensity := 1.0 # How bright/saturated the colors are

var shader_material: ShaderMaterial

func _ready():
	print("DEBUG: HealthUI _ready called")
	
	# Set up the health bar frame with a border
	if health_frame:
		health_frame.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0)) # Dark gray frame
		print("DEBUG: Health frame setup complete")
	else:
		print("ERROR: Health frame not found!")
	
	# Set up the health bar with trippy rainbow shader
	if health_bar:
		health_bar.visible = true
		print("DEBUG: Health bar setup complete - using ColorRect with shader")
		print("DEBUG: Health bar visible: ", health_bar.visible)
		print("DEBUG: Health bar type: ", health_bar.get_class())
		create_rainbow_shader() # Create the trippy shader effect
	else:
		print("ERROR: Health bar not found!")
		
	print("DEBUG: HealthUI _ready completed")

func create_rainbow_shader():
	print("DEBUG: Creating trippy scrolling rainbow shader")
	
	# Create a new shader
	var shader = Shader.new()
	
	# This is the magic! GLSL shader code for scrolling wiggly rainbow
	shader.code = """
	shader_type canvas_item;

	// Uniforms - these let us control the effect from GDScript
	uniform float scroll_speed : hint_range(0.0, 5.0) = 1.0;
	uniform float wiggle_intensity : hint_range(0.0, 1.0) = 0.3;
	uniform float wiggle_frequency : hint_range(1.0, 20.0) = 8.0;
	uniform float rainbow_intensity : hint_range(0.1, 2.0) = 1.0;

	// Function to convert HSV to RGB (for smooth rainbow colors)
	vec3 hsv_to_rgb(vec3 c) {
		vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
		vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
		return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

	void fragment() {
		// Get the current pixel position
		vec2 uv = UV;
		
		// Add wiggle effect using sine waves
		float wiggle_offset = sin(uv.x * wiggle_frequency + TIME * 2.0) * wiggle_intensity * 0.1;
		uv.y += wiggle_offset;
		
		// Create scrolling rainbow effect
		float rainbow_position = uv.x + TIME * scroll_speed;
		
		// Generate smooth rainbow colors using HSV
		float hue = fract(rainbow_position * 2.0); // 2.0 makes the rainbow repeat across the bar
		vec3 rainbow_color = hsv_to_rgb(vec3(hue, 1.0, rainbow_intensity));
		
		// Add some extra trippy effects
		float pulse = sin(TIME * 3.0) * 0.2 + 0.8; // Subtle pulsing brightness
		rainbow_color *= pulse;
		
		// Output the final color
		COLOR = vec4(rainbow_color, 1.0);
	}
	"""
	
	# Create shader material and apply it
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Set initial shader parameters
	update_shader_parameters()
	
	# Apply the shader to the health bar
	health_bar.material = shader_material
	
	print("DEBUG: Trippy scrolling rainbow shader created and applied!")

func update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("scroll_speed", rainbow_scroll_speed)
		shader_material.set_shader_parameter("wiggle_intensity", wiggle_intensity)
		shader_material.set_shader_parameter("wiggle_frequency", wiggle_frequency)
		shader_material.set_shader_parameter("rainbow_intensity", rainbow_intensity)

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
	
	# Adjust shader effects based on health level
	if health_percentage > 0.6:
		# High health - smooth, pleasant rainbow
		rainbow_scroll_speed = 1.0
		wiggle_intensity = 0.3
		rainbow_intensity = 1.0
		print("DEBUG: High health - smooth rainbow")
	elif health_percentage > 0.3:
		# Medium health - faster, more intense
		rainbow_scroll_speed = 1.5
		wiggle_intensity = 0.5
		rainbow_intensity = 1.2
		print("DEBUG: Medium health - intense rainbow")
	else:
		# Low health - crazy fast and wiggly
		rainbow_scroll_speed = 2.5
		wiggle_intensity = 0.8
		rainbow_intensity = 1.5
		print("DEBUG: Low health - CRAZY rainbow")
	
	# Apply the new parameters to the shader
	update_shader_parameters()
