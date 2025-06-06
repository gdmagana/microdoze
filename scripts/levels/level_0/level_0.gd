extends Node2D

@onready var player = $Player
@onready var bounce_hint_label = $Player/OnBounceLabel
@onready var oh_no_label = $Player/OhNoLabel
@onready var camera = $Player/Camera2D
@onready var ice_cream_boss = $EvilLactoseFreeIceCreamPixel
@onready var evil_label = $EvilLactoseFreeIceCreamPixel/EvilLabel
@onready var health_ui = $HUD/HealthUI
@onready var puck_counter = $HUD/PuckCounter
@onready var arrow1 = $ArrowIndicator
@onready var arrow2 = $ArrowIndicator2
var camera_original_position = Vector2.ZERO

var gave_first_nav_hint = false
var gave_second_nav_hint = false
var gave_bounce_hint = false

@export var projectile_icicle: PackedScene
var icicles_spawned = false

func _ready():
	add_to_group("level_zero")
	
	# Stop narrative audio when Level 0 starts
	stop_narrative_audio()
	
	player.max_health = 5
	player.health = 5
	player.can_shoot_puck = false
	player.connect("bounced_off_ice", Callable(self, "_on_player_bounce_off_ice"))
	
	_set_health_powerup_amount_for_level0()
	
func stop_narrative_audio():
	# Access the autoload using get_node to stop narrative audio
	var audio_manager = get_node("/root/NarrativeAudioManager")
	if audio_manager:
		audio_manager.stop_narrative_audio()
	else:
		print("Warning: NarrativeAudioManager not found")

func _set_health_powerup_amount_for_level0():
	var ice_cube_barrier2 = $IceCubeBarrier2
	if ice_cube_barrier2:
		var projectile_ice_cube5 = ice_cube_barrier2.get_node("ProjectileIceCube5")
		if projectile_ice_cube5 and "powerup_scene" in projectile_ice_cube5:
			var powerup_scene = projectile_ice_cube5.powerup_scene
			if powerup_scene:
				var powerup_instance = powerup_scene.instantiate()
				if "health_amount" in powerup_instance:
					powerup_instance.health_amount = 2
					var new_packed_scene = PackedScene.new()
					new_packed_scene.pack(powerup_instance)
					projectile_ice_cube5.powerup_scene = new_packed_scene
	
func _on_player_bounce_off_ice():
	if not gave_bounce_hint:
		arrow1.visible = false
		health_ui.visible = true
		bounce_hint_label.visible = true
		gave_bounce_hint = true
		player.can_shoot_puck = true
			
func _input(event):
	# once player moves, reveal arrow indicator
	if not gave_first_nav_hint and event is InputEventKey and event.pressed:
		if event.keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]:
			gave_first_nav_hint = true
			arrow1.visible = true
			arrow1.start_flashing()
			
	
	if bounce_hint_label.visible and Input.is_action_just_pressed("shoot_puck"):
		bounce_hint_label.visible = false
		puck_counter.visible = true

func _process(_delta):
	if not icicles_spawned and player.position.y <= -1200:
		await player.lock_player()
		await start_ice_cream_boss_initial_attack_sequence()
		await get_tree().create_timer(4).timeout
		ice_cream_boss.run_away()
		await get_tree().create_timer(1.6).timeout
		arrow2.visible = true
		arrow2.start_flashing()
		player.unlock_player()
		freeze_camera()
		
	if player.global_position.y <= -2000:
		start_level_one()
			
func freeze_camera():
	var root = get_tree().current_scene
	var camera_global_pos = camera.global_position
	camera.get_parent().remove_child(camera)
	root.add_child(camera)
	camera.global_position = camera_global_pos
			
func is_player_off_screen():
	var viewport_rect = Rect2(camera.global_position - get_viewport_rect().size / 2, get_viewport_rect().size)
	return not viewport_rect.has_point(player.global_position)
	
func spawn_icicles():
	var offsets = [-150, 0, 150] # left, center, right
	for offset in offsets:
		var icicle = projectile_icicle.instantiate()
		icicle.damage_amount = 1
		icicle.position = Vector2(player.position.x + offset, -2000)
		var direction = (player.position - icicle.position).normalized()
		icicle.velocity = direction * 400
		add_child(icicle)
	
func start_ice_cream_boss_initial_attack_sequence():
	spawn_icicles()
	icicles_spawned = true
	oh_no_label.visible = true
	await get_tree().create_timer(3.0).timeout
	oh_no_label.visible = false
	
	evil_label.visible = true
	_start_typewriter_concurrent(evil_label, "Hit me i dare you\n You'll never eat me \nMWAAHAHAhahaaa")
	camera.apply_shake()
	
func start_level_one():
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
