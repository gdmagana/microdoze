extends Node2D

@onready var player = $Player
@onready var bounce_hint_label = $Player/OnBounceLabel
@onready var oh_no_label = $Player/OhNoLabel
@onready var evil_label = $EvilLactoseFreeIceCreamPixel/EvilLabel
@onready var camera = $Player/Camera2D
var camera_original_position = Vector2.ZERO

var gave_bounce_hint = false

@export var projectile_icicle: PackedScene
var icicles_spawned = false

func _ready():
	add_to_group("level_zero")
	bounce_hint_label.visible = false
	oh_no_label.visible = false
	evil_label.visible = false
	
	# Stop narrative audio when Level 0 starts
	stop_narrative_audio()
	
	player.max_health = 5
	player.health = 5
	player.connect("bounced_off_ice", Callable(self, "_on_player_bounce_off_ice"))

func stop_narrative_audio():
	# Access the autoload using get_node to stop narrative audio
	var audio_manager = get_node("/root/NarrativeAudioManager")
	if audio_manager:
		audio_manager.stop_narrative_audio()
	else:
		print("Warning: NarrativeAudioManager not found")
	
func _on_player_bounce_off_ice():
	if not gave_bounce_hint:
		bounce_hint_label.visible = true
		gave_bounce_hint = true
			
func _input(_event):	
	if bounce_hint_label.visible and Input.is_action_just_pressed("shoot_puck"):
		bounce_hint_label.visible = false
	
func _process(_delta):
	if not icicles_spawned and player.position.y < -1300:
		spawn_icicles()
		icicles_spawned = true
		lock_player()
		await start_ice_cream_boss_initial_attack_sequence()
		start_level_one()
		
func spawn_icicles():
	var offsets = [-150, 0, 150] # left, center, right
	for offset in offsets:
		var icicle = projectile_icicle.instantiate()
		icicle.position = Vector2(player.position.x + offset, -2000)
		var direction = (player.position - icicle.position).normalized()
		icicle.velocity = direction * 400
		add_child(icicle)
	
func lock_player():
	player.can_move_horizontally = false
	player.can_move_vertically = false
	
func start_ice_cream_boss_initial_attack_sequence():
	oh_no_label.visible = true
	await get_tree().create_timer(3.0).timeout
	oh_no_label.visible = false
	evil_label.visible = true
	_start_typewriter_concurrent(evil_label, "Catch me if you can \nMWAAHAHAhahaaa")
	camera.apply_shake()
	
func start_level_one():
	await get_tree().create_timer(2).timeout # short pause before transition
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")
	
# Helper function to start typewriter effect concurrently
func _start_typewriter_concurrent(label: Label, text: String):
	# Use call_deferred to start the coroutine without blocking
	call_deferred("_run_typewriter", label, text)

# Internal function to run the typewriter effect
func _run_typewriter(label: Label, text: String):
	await show_typewriter_text(label, text)
	
# Typewriter effect for dialog text (similar to narrative scenes)
func show_typewriter_text(label: Label, full_text: String):
	label.text = ""
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(0.05, true).timeout  # 0.05 seconds per character
