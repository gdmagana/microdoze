extends Area2D

@export var projectile_ice_cube_scene: PackedScene
@export var projectile_ice_cream_scoop: PackedScene
@export var projectile_icicle: PackedScene

@export var throw_speed := 400.0
@export var max_health := 100.0
@export var health := 100.0
@export var damage_flash_duration := 0.3

# Boss sprite textures for different health states
@export_group("Boss Sprites")
@export var sprite_full_health: Texture2D # When health > 75%
@export var sprite_damaged_once: Texture2D # When health 50-75%
@export var sprite_damaged_twice: Texture2D # When health 25-50%
@export var sprite_raging: Texture2D # When health 0-25% (raging state)

# Powerup integration
@export_group("Powerups")
@export var powerup_drop_chance := 0.15 # 15% chance for ice cubes to have powerups

# Powerup probability weights (higher = more likely)
@export_subgroup("Powerup Probabilities")
@export var speed_boost_weight := 1.0 # Default equal chance
@export var unlimited_pucks_weight := 1.0 # Default equal chance
@export var fire_pucks_weight := 1.0 # Default equal chance
@export var invincibility_weight := 0.5 # Half as likely (since it's powerful)
@export var health_weight := 1.5 # Slightly more likely since health is valuable but not overpowered

var powerup_scenes = []
var powerup_weights = []

# randomness used for later
var rng = RandomNumberGenerator.new()

var player: Node2D
var is_raging := false

# Health bar reference
var health_bar: Control

# used to keep track of current level
var level := 0

# Ice cube tracking system to prevent overlapping ice cubes
var active_ice_cubes = {} # Dictionary to track ice cubes by position key

signal ran_away

func _ready():
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "Level2":
		level = 2
		$Timer.wait_time = 0.75
	else:
		level = 1
	print(level)
	add_to_group("boss")
	player = get_tree().get_current_scene().find_child("Player", true, false)
	$Timer.timeout.connect(_on_Timer_timeout)
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	# Initialize sprite based on current health
	update_sprite_for_health_state()
	
	# Load powerup scenes
	_load_powerup_scenes()
	
	# Initialize health bar
	health_bar = $BossHealthBar
	if health_bar:
		health_bar.update_health(health, max_health)
	
	# Hide dialog panel initially
	$BossDialog1.visible = false

func _load_powerup_scenes():
	# Load all available powerup scenes with their corresponding weights
	powerup_scenes = [
		preload("res://scenes/power_ups/SpeedBoostPowerUp.tscn"),
		preload("res://scenes/power_ups/UnlimitedPucksPowerUp.tscn"),
		preload("res://scenes/power_ups/FirePucksPowerUp.tscn"),
		preload("res://scenes/power_ups/InvincibilityPowerUp.tscn"),
		preload("res://scenes/power_ups/HealthPowerUp.tscn")
	]
	
	# Set up weights array to match the scenes array
	powerup_weights = [
		speed_boost_weight,
		unlimited_pucks_weight,
		fire_pucks_weight,
		invincibility_weight,
		health_weight
	]
	
	print("  Speed Boost: ", speed_boost_weight)
	print("  Unlimited Pucks: ", unlimited_pucks_weight)
	print("  Fire Pucks: ", fire_pucks_weight)
	print("  Invincibility: ", invincibility_weight)
	print("  Health: ", health_weight)

func get_weighted_random_powerup() -> PackedScene:
	# Calculate total weight
	var total_weight = 0.0
	for weight in powerup_weights:
		if weight > 0: # Only count positive weights
			total_weight += weight
	
	if total_weight <= 0:
		print("WARNING: All powerup weights are 0 or negative!")
		return null
	
	# Generate random number between 0 and total_weight
	var random_value = randf() * total_weight
	
	# Find which powerup this random value corresponds to
	var current_weight = 0.0
	for i in range(powerup_scenes.size()):
		if powerup_weights[i] > 0: # Skip powerups with 0 or negative weight
			current_weight += powerup_weights[i]
			if random_value <= current_weight:
				var selected_powerup = powerup_scenes[i]
				return selected_powerup
	
	# Fallback (shouldn't happen with proper weights)
	print("WARNING: Weighted selection failed, using first powerup")
	return powerup_scenes[0]

func _on_body_entered(body):
	if body.is_in_group("puck"):
		# Use call_deferred to avoid changing physics state during physics processing
		call_deferred("take_damage")
		if body.has_method("destroy_puck"):
			body.destroy_puck()
		

	if body.is_in_group("ice_cube"):
		# If an ice cube hits the boss, take damage
		call_deferred("take_damage")
	
func _on_Timer_timeout():
	if player:
		rng.randomize()
		var random_number = rng.randi_range(0, 2)

		var projectile
		var direction
		
		if level == 1:
			projectile = projectile_icicle.instantiate()
			direction = (player.global_position - global_position).normalized()
		
		elif level == 2:
			if random_number < 2:
				# "throw" the icicle projectiles at the player
				projectile = projectile_icicle.instantiate()
				direction = (player.global_position - global_position).normalized()
			else:
				# "throw" the ice cream scoop at a random position
				projectile = projectile_ice_cream_scoop.instantiate()
				
				# Pick a random x within screen width, y slightly below screen
				var viewport_size = get_viewport().get_visible_rect().size
				var random_x = rng.randi_range(0, int(viewport_size.x))
				var target_point = Vector2(random_x, viewport_size.y + 100)
				direction = (target_point - global_position).normalized()

		get_parent().add_child(projectile)
		projectile.global_position = global_position
		projectile.velocity = direction * throw_speed

func update_sprite_for_health_state():
	var current_texture: Texture2D = null
	var health_percentage = health / max_health
	
	if health_percentage > 0.75:
		current_texture = sprite_full_health
	elif health_percentage > 0.5:
		current_texture = sprite_damaged_once
	elif health_percentage > 0.25:
		current_texture = sprite_damaged_twice
	else:
		current_texture = sprite_raging
	
	# Only update if we have a texture assigned, otherwise keep current
	if current_texture != null:
		$Sprite2D.texture = current_texture

func take_damage(amount := 25.0):
	health -= amount
	health = max(health, 0.0) # Prevent negative health
	
	# Update health bar
	if health_bar:
		health_bar.update_health(health, max_health)
		health_bar.flash_damage()
	
	# Play damage sound if we can find one
	# if get_node_or_null("../audio/Pain1") != null:
	
	# Update sprite for new health state
	update_sprite_for_health_state()
	
	# Flash red
	damage_flash()

	# Dramatic pause, zoom, and dialog sequence
	call_deferred("dramatic_damage_sequence")
	
	# Do wave that kills nearby pucks??
	
	if not is_raging and health <= 0:
		rage()
	else:
		throw_ice_wall(-200)

func dramatic_damage_sequence():
# Sequence: pause, zoom, dialog, unzoom, resume
	# Ensure this function is called in a deferred manner to avoid issues with physics processing
	await get_tree().create_timer(0.1).timeout
	
	# If the boss is already raging, just flash and return
	if is_raging:
		damage_flash()
		return
	
	# Start the dramatic damage sequence
	await _dramatic_damage_sequence()


func _dramatic_damage_sequence():
	# Make ourselves immune to pausing temporarily
	var _original_process_mode = process_mode
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Store current scene elements
	var camera = get_viewport().get_camera_2d()
	var original_zoom = camera.zoom if camera else Vector2(1, 1)
	var original_camera_pos = camera.global_position if camera else Vector2.ZERO
	
	var dialog_panel = $BossDialog1
	var dialog_label = $BossDialog1/BossDialog1Label
	
	# Set process mode for dialog components
	dialog_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	dialog_label.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# ensure the boss music continues playing
	var boss_music = get_tree().get_current_scene().get_node_or_null("audio/BossMusic")
	if boss_music:
		boss_music.process_mode = Node.PROCESS_MODE_ALWAYS

	# Pause the game
	get_tree().paused = true

	if camera:
		# Get boss position as our reference point
		var viewport_size = get_viewport().get_visible_rect().size
		var zoom_target = Vector2(1.3, 1.3) # Zoom in for dramatic effect
		
		# Position dialog box relative to boss to ensure it's visible in zoomed view
		dialog_panel.position = Vector2(250, -150) # To the right of the boss
		
		# Calculate camera offset to show top-right area
		# Move camera up and right from current position to focus on top-right area
		var offset_factor = 0.3 # How much to offset (30% of current view)
		var camera_offset = Vector2(
			viewport_size.x * offset_factor / original_zoom.x, # Move right
			- viewport_size.y * offset_factor / original_zoom.y # Move up (negative Y)
		)
		var target_camera_pos = original_camera_pos + camera_offset

		# Show dialog panel and start zoom and typewriter effect concurrently
		dialog_panel.visible = true
		
		# Start both zoom and typewriter effect at the same time
		var zoom_tween = create_tween()
		zoom_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		zoom_tween.parallel().tween_property(camera, "zoom", zoom_target, 0.4)
		zoom_tween.parallel().tween_property(camera, "global_position", target_camera_pos, 0.4)
		
		# Start typewriter effect as a concurrent task
		var dialog_text = GameState.boss_dialogues[GameState.curr_dialogue]
		GameState.curr_dialogue = (GameState.curr_dialogue + 1) % len(GameState.boss_dialogues)
		#if hits_to_ice_wall_rage == 1:
			#dialog_text = "You lactose intolerant slut"
		_start_typewriter_concurrent(dialog_label, dialog_text)
		
		# Wait for zoom to complete
		await zoom_tween.finished

		# Wait using a proper timer
		await get_tree().create_timer(1.6, true).timeout

		# Unzoom and move camera back concurrently
		var unzoom_tween = create_tween()
		unzoom_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		unzoom_tween.parallel().tween_property(camera, "zoom", original_zoom, 0.4)
		unzoom_tween.parallel().tween_property(camera, "global_position", original_camera_pos, 0.4)
		await unzoom_tween.finished
	else:
		# No camera case - just show dialog with typewriter effect and wait
		dialog_panel.visible = true
		await show_typewriter_text(dialog_label, "Your mom never loved you!")
		await get_tree().create_timer(1.2, true).timeout

	# Hide dialog and reset its position
	dialog_panel.visible = false
	dialog_panel.position = Vector2(248, -139) # Reset to original scene position

	# Restore original process mode and unpause
	process_mode = _original_process_mode
	resume_game()

# Typewriter effect for dialog text (similar to narrative scenes)
func show_typewriter_text(label: Label, full_text: String):
	label.text = ""
	for i in range(full_text.length()):
		label.text += full_text[i]
		await get_tree().create_timer(0.05, true).timeout # 0.05 seconds per character

# Helper function to start typewriter effect concurrently
func _start_typewriter_concurrent(label: Label, text: String):
	# Use call_deferred to start the coroutine without blocking
	call_deferred("_run_typewriter", label, text)

# Internal function to run the typewriter effect
func _run_typewriter(label: Label, text: String):
	await show_typewriter_text(label, text)

# Resume the game after the sequence
func resume_game():
	get_tree().paused = false

# Flash the boss red when taking damage
func damage_flash():
	# Set sprite to red
	$Sprite2D.modulate = Color(1, 0, 0)
	
	# Create a tween to fade back to normal
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), damage_flash_duration)

func rage():
	is_raging = true
	# Update sprite for raging state
	update_sprite_for_health_state()
	run_away()
	call_deferred("throw_ice_wall")
	
func throw_ice_wall(y_offset = null):
	var screen_width = get_viewport_rect().size.x
	var ice_cube_width = 100
	var y_pos = null
	if not y_offset:
		y_pos = global_position.y - 100
	else:
		y_pos = global_position.y - y_offset
	
	for x in range(0, screen_width, ice_cube_width):
		var ice_cube_x = x + ice_cube_width / 2.0
		var position_key = get_position_key(ice_cube_x, y_pos)
		
		# Only create ice cube if position is not occupied
		if not active_ice_cubes.has(position_key):
			var ice_cube = projectile_ice_cube_scene.instantiate()
			
			# Add powerup chance to some ice cubes using weighted selection
			if randf() < powerup_drop_chance and powerup_scenes.size() > 0:
				var selected_powerup = get_weighted_random_powerup()
				if selected_powerup:
					ice_cube.set_powerup(selected_powerup, 1.0) # 100% drop chance if selected
			
			get_parent().add_child(ice_cube)
			ice_cube.global_position = Vector2(ice_cube_x, y_pos)
			
			# Track this ice cube
			active_ice_cubes[position_key] = ice_cube
			
			# Connect to ice cube's tree_exiting signal to clean up tracking
			ice_cube.connect("tree_exiting", Callable(self, "_on_ice_cube_destroyed").bind(position_key))

# Helper function to create a position key for tracking ice cubes
func get_position_key(x: float, y: float) -> String:
	# Round positions to nearest 10 pixels to handle slight position differences
	var rounded_x = round(x / 10) * 10
	var rounded_y = round(y / 10) * 10
	return str(rounded_x) + "," + str(rounded_y)

# Called when an ice cube is destroyed to remove it from tracking
func _on_ice_cube_destroyed(position_key: String):
	if active_ice_cubes.has(position_key):
		active_ice_cubes.erase(position_key)

func run_away():
	var player = get_parent().get_node("Player")
	player.canMoveUp = true
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 300, 1.5)
	tween.tween_callback(Callable(self, "queue_free"))
	emit_signal("ran_away")
