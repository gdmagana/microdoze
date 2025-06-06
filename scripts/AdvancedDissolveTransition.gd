extends Control
class_name AdvancedDissolveTransition

@export var normal_texture: Texture2D
@export var psychedelic_texture: Texture2D
@export var transition_duration: float = 2.0
@export var auto_start: bool = true
@export var start_delay: float = 1.0
@export var dissolve_softness: float = 0.1

var container: Control
var normal_sprite: Sprite2D
var psychedelic_sprite: Sprite2D
var dissolve_material: ShaderMaterial
var tween: Tween

func _ready():
	setup_advanced_dissolve()
	if auto_start:
		await get_tree().create_timer(start_delay).timeout
		start_transition_to_psychedelic()

func setup_advanced_dissolve():
	# Create container for the dissolve effect
	container = Control.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(container)
	
	# Create normal background sprite (base layer)
	normal_sprite = Sprite2D.new()
	normal_sprite.texture = normal_texture
	normal_sprite.position = Vector2(540, 640)
	normal_sprite.scale = Vector2(1.06, 0.85)
	container.add_child(normal_sprite)
	
	# Create psychedelic background sprite (dissolve layer)
	psychedelic_sprite = Sprite2D.new()
	psychedelic_sprite.texture = psychedelic_texture
	psychedelic_sprite.position = Vector2(540, 640)
	psychedelic_sprite.scale = Vector2(1.06, 0.85)
	container.add_child(psychedelic_sprite)
	
	# Create dissolve shader
	create_dissolve_shader()

func create_dissolve_shader():
	# Create shader material for dissolve effect
	dissolve_material = ShaderMaterial.new()
	
	# Create simple dissolve shader
	var shader_code = """
	shader_type canvas_item;
	
	uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.0;
	uniform float edge_width : hint_range(0.0, 0.2) = 0.05;
	uniform vec4 edge_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);
	
	float random(vec2 uv) {
		return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
	}
	
	void fragment() {
		vec2 noise_uv = UV * 5.0;
		float noise = random(floor(noise_uv) / 5.0);
		
		float dissolve_mask = step(noise, dissolve_amount);
		float edge_mask = step(noise, dissolve_amount + edge_width) - dissolve_mask;
		
		vec4 original_color = texture(TEXTURE, UV);
		vec4 final_color = mix(original_color, edge_color, edge_mask);
		
		COLOR = final_color;
		COLOR.a *= dissolve_mask + edge_mask;
	}
	"""
	
	var shader = Shader.new()
	shader.code = shader_code
	dissolve_material.shader = shader
	
	# Apply shader to psychedelic sprite
	psychedelic_sprite.material = dissolve_material
	
	# Set initial dissolve amount
	dissolve_material.set_shader_parameter("dissolve_amount", 0.0)

func start_transition_to_psychedelic():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(set_dissolve_amount, 0.0, 1.0, transition_duration)

func start_transition_to_normal():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(set_dissolve_amount, 1.0, 0.0, transition_duration)

func set_dissolve_amount(value: float):
	if dissolve_material:
		dissolve_material.set_shader_parameter("dissolve_amount", value)

func toggle_background():
	var current_dissolve = dissolve_material.get_shader_parameter("dissolve_amount")
	if current_dissolve > 0.5:
		start_transition_to_normal()
	else:
		start_transition_to_psychedelic()
