extends Control
class_name DissolveTransition

@export var normal_texture: Texture2D
@export var psychedelic_texture: Texture2D
@export var transition_duration: float = 2.0
@export var auto_start: bool = true
@export var start_delay: float = 1.0

var normal_sprite: Sprite2D
var psychedelic_sprite: Sprite2D
var tween: Tween

func _ready():
	setup_sprites()
	if auto_start:
		await get_tree().create_timer(start_delay).timeout
		start_transition_to_psychedelic()

func setup_sprites():
	# Create normal background sprite
	normal_sprite = Sprite2D.new()
	normal_sprite.texture = normal_texture
	normal_sprite.position = Vector2(540, 640)  # Center of screen
	normal_sprite.scale = Vector2(1.06, 0.85)   # Match existing scale
	add_child(normal_sprite)
	
	# Create psychedelic background sprite
	psychedelic_sprite = Sprite2D.new()
	psychedelic_sprite.texture = psychedelic_texture
	psychedelic_sprite.position = Vector2(540, 640)
	psychedelic_sprite.scale = Vector2(1.06, 0.85)
	psychedelic_sprite.modulate.a = 0.0  # Start invisible
	add_child(psychedelic_sprite)

func start_transition_to_psychedelic():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.parallel().tween_property(psychedelic_sprite, "modulate:a", 1.0, transition_duration)
	tween.parallel().tween_property(normal_sprite, "modulate:a", 0.0, transition_duration)

func start_transition_to_normal():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.parallel().tween_property(psychedelic_sprite, "modulate:a", 0.0, transition_duration)
	tween.parallel().tween_property(normal_sprite, "modulate:a", 1.0, transition_duration)

func toggle_background():
	if psychedelic_sprite.modulate.a > 0.5:
		start_transition_to_normal()
	else:
		start_transition_to_psychedelic()
