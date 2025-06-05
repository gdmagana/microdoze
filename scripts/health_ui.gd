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
	# Set up the health bar frame with a border
	if health_frame:
		health_frame.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 1.0)) # Dark gray frame
	else:
		print("ERROR: Health frame not found!")
	
	# Set up the health bar with trippy rainbow shader
	if health_bar:
		health_bar.visible = true
		create_rainbow_shader() # Create the trippy shader effect
	else:
		print("ERROR: Health bar not found!")
		
func create_rainbow_shader():
	# Create a new shader
	var shader = Shader.new()
	
	# Pixelated stair-step rainbow shader code with health-based clipping
	shader.code = """
	shader_type canvas_item;

	// Uniforms for controlling the pixelated rainbow effect
	uniform float scroll_speed : hint_range(0.0, 5.0) = 1.0;
	uniform float pixel_height_fraction : hint_range(0.1, 1.0) = 0.333; // 1/3 of health bar height
	uniform float step_width : hint_range(8.0, 64.0) = 32.0; // Width of each color block
	uniform float step_height : hint_range(0.1, 1.0) = 0.333; // Height of each step (1/3)
	uniform float health_percentage : hint_range(0.0, 1.0) = 1.0; // Health percentage for clipping

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
		
		// Clip based on health percentage - maintain texture scale but cut off at the right
		if (uv.x > health_percentage) {
			discard; // Don't render pixels beyond health percentage
		}
		
		// Create stair-step pattern: each row has a static offset
		float stair_row = floor(uv.y / pixel_height_fraction); // Which pixel row we're in
		float stair_offset = mod(stair_row, 4.0) * 0.03; // Offset each row by different amounts (0, 0.2, 0.4, 0.6)
		
		// Apply horizontal scrolling with row offset (all move at same speed)
		float scrolled_x = uv.x - TIME * scroll_speed + stair_offset;
		
		// Create pixelated blocks - quantize to discrete grid
		float block_x = floor(scrolled_x * step_width);
		float block_y = floor(uv.y / pixel_height_fraction);
		
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
	
func update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("scroll_speed", rainbow_scroll_speed)
		# Keep pixel height as 1/3 consistently 
		shader_material.set_shader_parameter("pixel_height_fraction", 0.333)
		# Pass current health percentage to shader for clipping
		shader_material.set_shader_parameter("health_percentage", current_health_percentage)
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

func update_health(current_health: float, max_health: float):
	if not health_bar:
		print("ERROR: health_bar is null in update_health!")
		return
		
	# Calculate health percentage
	var health_percentage = clamp(current_health / max_health, 0.0, 1.0)
	current_health_percentage = health_percentage
	
	# Reset health bar to full size - the shader will handle clipping
	health_bar.anchor_left = 0.0
	health_bar.anchor_right = 1.0
	health_bar.anchor_top = 0.0
	health_bar.anchor_bottom = 1.0
	health_bar.offset_left = 3.0
	health_bar.offset_top = 3.0
	health_bar.offset_right = -3.0
	health_bar.offset_bottom = -3.0
	
	# Adjust shader effects based on health level
	if health_percentage > 0.6:
		# High health - smooth, pleasant scrolling with smaller blocks
		rainbow_scroll_speed = 0.3
	elif health_percentage > 0.3:
		# Medium health - faster scrolling with medium blocks
		rainbow_scroll_speed = 0.5
	else:
		# Low health - rapid scrolling with larger, chunkier blocks
		rainbow_scroll_speed = 0.7
	
	# Apply the new parameters to the shader
	update_shader_parameters()
