extends Sprite2D
class_name DissolveBackground

@export var normal_texture: Texture2D
@export var psychedelic_texture: Texture2D
@export var noise_texture: Texture2D
@export var dissolve_duration: float = 2.0
@export var auto_start_dissolve: bool = false
@export var dissolve_delay: float = 1.0

var shader_material: ShaderMaterial
var tween: Tween
var is_psychedelic: bool = false

func _ready():
	setup_dissolve_shader()
	if auto_start_dissolve:
		await get_tree().create_timer(dissolve_delay).timeout
		start_dissolve_to_psychedelic()

func setup_dissolve_shader():
	# Create shader material
	shader_material = ShaderMaterial.new()
	var shader = load("res://assets/shaders/dissolve_background.gdshader")
	shader_material.shader = shader
	
	# Set material to the sprite
	material = shader_material
	
	# Set shader parameters
	if normal_texture:
		shader_material.set_shader_parameter("normal_background", normal_texture)
	if psychedelic_texture:
		shader_material.set_shader_parameter("psychedelic_background", psychedelic_texture)
	if noise_texture:
		shader_material.set_shader_parameter("noise_texture", noise_texture)
	else:
		# Create a simple noise texture if none provided
		create_noise_texture()
	
	# Set initial dissolve amount to 0 (normal background)
	shader_material.set_shader_parameter("dissolve_amount", 0.0)
	shader_material.set_shader_parameter("noise_scale", 1.0)

func create_noise_texture():
	# Create a simple procedural noise texture
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1
	
	var noise_texture_2d = NoiseTexture2D.new()
	noise_texture_2d.noise = noise
	noise_texture_2d.width = 512
	noise_texture_2d.height = 512
	
	shader_material.set_shader_parameter("noise_texture", noise_texture_2d)

func start_dissolve_to_psychedelic():
	if is_psychedelic:
		return
		
	is_psychedelic = true
	animate_dissolve(0.0, 1.0)

func start_dissolve_to_normal():
	if not is_psychedelic:
		return
		
	is_psychedelic = false
	animate_dissolve(1.0, 0.0)

func animate_dissolve(from_value: float, to_value: float):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_method(set_dissolve_amount, from_value, to_value, dissolve_duration)

func set_dissolve_amount(value: float):
	if shader_material:
		shader_material.set_shader_parameter("dissolve_amount", value)

func toggle_background():
	if is_psychedelic:
		start_dissolve_to_normal()
	else:
		start_dissolve_to_psychedelic()
