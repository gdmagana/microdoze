extends Control

@onready var health_bar: ColorRect = $HealthBarContainer/HealthBarFrame/HealthBar
@onready var health_frame: Panel = $HealthBarContainer/HealthBarFrame
@onready var progress_background: Panel = $HealthBarContainer/ProgressBarBackground

var low_health_tween: Tween
var rainbow_tween: Tween
var current_health_percentage: float = 1.0

# Shader effect variables - CUSTOMIZE THESE FOR PIXELATED RAINBOW EFFECT
var rainbow_scroll_speed := 1.0 # How fast the rainbow scrolls (higher = faster)

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
	print("DEBUG: Creating pixelated stair-step rainbow shader")
	
	# Create a new shader
	var shader = Shader.new()
	
	# Pixelated stair-step rainbow shader code
	shader.code = """
	shader_type canvas_item;

	// Uniforms for controlling the pixelated rainbow effect
	uniform float scroll_speed : hint_range(0.0, 5.0) = 1.0;
	uniform float pixel_height_fraction : hint_range(0.1, 1.0) = 0.333; // 1/3 of health bar height
	uniform float step_width : hint_range(8.0, 64.0) = 32.0; // Width of each color block
	uniform float step_height : hint_range(0.1, 1.0) = 0.333; // Height of each step (1/3)

	// Function to get 8-color rainbow palette
	vec3 get_rainbow_color(int color_index) {
		// 8 vibrant rainbow colors
		vec3 colors[8];
		colors[0] = vec3(1.0, 0.0, 0.0);    // Red
		colors[1] = vec3(1.0, 0.5, 0.0);    // Orange  
		colors[2] = vec3(1.0, 1.0, 0.0);    // Yellow
		colors[3] = vec3(0.0, 1.0, 0.0);    // Green
		colors[4] = vec3(0.0, 1.0, 1.0);    // Cyan
		colors[5] = vec3(0.0, 0.0, 1.0);    // Blue
		colors[6] = vec3(0.5, 0.0, 1.0);    // Purple
		colors[7] = vec3(1.0, 0.0, 1.0);    // Magenta
		
		return colors[color_index];
	}

	void fragment() {
		vec2 uv = UV;
		
		// Apply horizontal scrolling
		float scrolled_x = uv.x - TIME * scroll_speed;
		
		// Create pixelated blocks - quantize to discrete grid
		float block_x = floor(scrolled_x * step_width);
		float block_y = floor(uv.y / pixel_height_fraction);
		
		// Create stair-step pattern: each step moves down as we go right
		float stair_offset = mod(block_x, 3.0); // 3-step pattern for clean stairs
		float adjusted_y = block_y + stair_offset;
		
		// Determine which color to use based on horizontal position
		int color_index = int(mod(block_x, 8.0)); // Cycle through 8 colors
		
		// Get the rainbow color for this block
		vec3 rainbow_color = get_rainbow_color(color_index);
		
		// Make sure we're within the pixelated grid
		float pixel_y = mod(uv.y, pixel_height_fraction);
		
		// Create clean pixel boundaries (no anti-aliasing for crisp retro look)
		if (pixel_y < pixel_height_fraction * 0.95) { // Small gap between pixel rows for definition
			COLOR = vec4(rainbow_color, 1.0);
		} else {
			// Subtle dark outline between pixels for better definition
			COLOR = vec4(rainbow_color * 0.8, 1.0);
		}
	}
	"""
	
	# Create shader material and apply it
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Set initial shader parameters
	update_shader_parameters()
	
	# Apply the shader to the health bar
	health_bar.material = shader_material
	
	print("DEBUG: Pixelated stair-step rainbow shader created and applied!")

func update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("scroll_speed", rainbow_scroll_speed)
		# Keep pixel height as 1/3 consistently 
		shader_material.set_shader_parameter("pixel_height_fraction", 0.333)
		# Adjust step width based on health level for more/less detail
		var step_width = 32.0
		if current_health_percentage > 0.6:
			step_width = 24.0 # Smaller blocks when healthy
		elif current_health_percentage > 0.3:
			step_width = 32.0 # Medium blocks
		else:
			step_width = 48.0 # Larger, chunkier blocks when low health
		shader_material.set_shader_parameter("step_width", step_width)
		shader_material.set_shader_parameter("step_height", 0.333)

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
		# High health - smooth, pleasant scrolling with smaller blocks
		rainbow_scroll_speed = 0.3
		print("DEBUG: High health - smooth pixelated rainbow")
	elif health_percentage > 0.3:
		# Medium health - faster scrolling with medium blocks
		rainbow_scroll_speed = 0.6
		print("DEBUG: Medium health - faster pixelated rainbow")
	else:
		# Low health - rapid scrolling with larger, chunkier blocks
		rainbow_scroll_speed = 1.2
		print("DEBUG: Low health - CRAZY fast pixelated rainbow")
	
	# Apply the new parameters to the shader
	update_shader_parameters()
