extends CharacterBody2D

@onready var health_ui = get_tree().get_current_scene().get_node("HUD/HealthUI")
@onready var puck_counter = get_tree().get_current_scene().get_node("HUD/PuckCounter")
@onready var ouch_label: Label = $Ouch

# -- Player Health --
@export var max_health := 50.0
@export var health := 50.0

# -- Player Movement --
@export var acceleration := 800.0
@export var friction := 600.0
@export var max_speed := 500.0

var can_move_vertically := true
var can_move_horizontally := true

var is_frozen := false
var frozen_timer := 0.0

var is_invulnerable := false
var invulnerable_timer := 0.0

# Rainbow effect for invincibility
var rainbow_tween: Tween
var original_modulate: Color

# Character rotation for movement
var rotation_tween: Tween
var movement_rotation_angle := 60.0 # degrees
var rotation_speed := 0.2 # seconds to complete rotation

# Speed boost echo effect
var echo_sprites = []
var echo_timer := 0.0
var echo_interval := 0.05 # Create echo every 0.05 seconds (faster)
var speed_boost_echo_active := false
var echo_color_index := 0 # Track current color in rainbow cycle

# Fire pucks stick effect
var fire_stick_tween: Tween
var stick_original_modulate: Color

# -- Stick --
var last_direction := 1 # 1 = right, -1 = left
var stick_push_timer := 0.0
var stick_push_duration := 0.15 # seconds
var is_stick_pushing := false
var stick_base_offset := Vector2(30, -30)
var stick_extended_offset := Vector2(30, -25)
var stick_rotation_max := -0.5 # Maximum rotation in radians

var canMoveUp = false

# -- Puck --
@export var puck_scene: PackedScene
@export var puck_speed := 700.0
@export var max_active_pucks := 5 # Maximum number of active pucks allowed
@export var puck_cooldown := 0.5 # Time in seconds between puck shots
var active_pucks := 0 # Current number of active pucks
var puck_cooldown_timer := 0.0 # Timer for puck shooting cooldown
var can_shoot_puck = true
var is_puck_cooldown_complete = true

# -- Stage Bounds --
var stage_width
var stage_height

# -- Using this for scene changes
var scene_change_triggered := false # prevents switching multiple times

# -- Level-Specific Logic --
var is_level_zero := false
signal bounced_off_ice

func _ready():
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "TheEnd":
		canMoveUp = true
	GameState.current_level_path = get_tree().current_scene.scene_file_path
	add_to_group("player")
	
	# Safety check for Stick node
	var stick_node = get_node_or_null("Stick")
	if stick_node != null:
		stick_node.add_to_group("player_stick")
	else:
		print("ERROR: Stick node is null in player _ready()")
		# Try to print all children to debug
		print("DEBUG: Player children: ")
		for child in get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
	
	stage_width = get_viewport_rect().size.x
	stage_height = get_viewport_rect().size.y
	
	var center_x = stage_width / 2
	var start_position = Vector2(center_x, stage_height - 150)
	var entry_position = Vector2(center_x, stage_height + 100)
	# Set entry position and freeze
	global_position = entry_position
	is_frozen = true
	
	# Start entry animation
	var tween = create_tween()
	tween.tween_property(self, "global_position", start_position, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(Callable(self, "_on_intro_finished"))
	
	if GameState.current_level_path != "res://scenes/TheEnd.tscn":
		# Player health
		if health_ui:
			health_ui.update_health(health, max_health)
		if puck_counter:
			puck_counter.update_puck_count(max_active_pucks, active_pucks)
		
		# Safety check for Hitbox node
		if $Hitbox != null:
			$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
		else:
			print("ERROR: Hitbox node is null in player _ready()")
	
	# Store original color for rainbow effect with safety check
	if $Sprite2D != null:
		original_modulate = $Sprite2D.modulate
	else:
		print("ERROR: Sprite2D node is null in player _ready()")
		original_modulate = Color.WHITE
	
	# Store original colors for effects with safety check
	var stick_for_color = get_node_or_null("Stick")
	if stick_for_color != null and stick_for_color.get_node_or_null("Sprite2D") != null:
		stick_original_modulate = stick_for_color.get_node("Sprite2D").modulate
	else:
		print("ERROR: Stick/Sprite2D node is null in player _ready()")
		stick_original_modulate = Color.WHITE
	
	# Connect to PowerUpManager signals if available
	if PowerUpManager:
		print("DEBUG: Connecting to PowerUpManager signals...")
		PowerUpManager.invincibility_started.connect(_on_invincibility_started)
		PowerUpManager.invincibility_ended.connect(_on_invincibility_ended)
		PowerUpManager.speed_boost_started.connect(_on_speed_boost_started)
		PowerUpManager.speed_boost_ended.connect(_on_speed_boost_ended)
		PowerUpManager.fire_pucks_started.connect(_on_fire_pucks_started)
		PowerUpManager.fire_pucks_ended.connect(_on_fire_pucks_ended)
		print("DEBUG: All PowerUpManager signals connected!")
		
	call_deferred("_check_is_level_zero")
	
func _check_is_level_zero():
	if get_parent().is_in_group("level_zero"):
		is_level_zero = true
	
func _physics_process(delta):
	if is_frozen:
		frozen_timer -= delta
		if frozen_timer <= 0:
			is_frozen = false
			$Sprite2D.modulate = original_modulate # back to normal (or rainbow if invincible)
		return # skip movement while frozen
	
	# Handle echo effect timer for speed boost
	if speed_boost_echo_active:
		echo_timer -= delta
		if echo_timer <= 0:
			create_movement_echo()
			echo_timer = echo_interval # Reset timer
	
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1

	# Get speed multiplier from PowerUpManager
	var speed_multiplier = 1.0
	if PowerUpManager:
		speed_multiplier = PowerUpManager.get_speed_multiplier()

	# -- Movement Physics --
	# Horizontal
	if input_direction.x != 0:
		last_direction = sign(input_direction.x)
		if can_move_horizontally:
			velocity.x += input_direction.x * acceleration * speed_multiplier * delta
			
		# Apply character rotation based on movement direction
		apply_movement_rotation(input_direction.x)
	else:
		# Apply friction to gradually stop
		if abs(velocity.x) < friction * delta:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * friction * delta
		
		# Return to neutral rotation when not moving horizontally
		apply_movement_rotation(0.0)
			
	# clamp max horizontal speed (with speed multiplier)
	var current_max_speed = max_speed * speed_multiplier
	velocity.x = clamp(velocity.x, -current_max_speed, current_max_speed)
	
	# Vertical
	if can_move_vertically:
		if input_direction.y != 0:
				velocity.y += input_direction.y * acceleration * speed_multiplier * delta
		else:
			if abs(velocity.y) < friction * delta:
				velocity.y = 0
			else:
				velocity.y -= sign(velocity.y) * friction * delta
				
			velocity.y = clamp(velocity.y, -current_max_speed, current_max_speed)
	else:
		velocity.y = 0

	move_and_slide()
	
	# Update fire aura position to follow stick
	var fire_aura = get_node_or_null("FireAura")
	if fire_aura and is_instance_valid(fire_aura) and $Stick != null:
		fire_aura.position = $Stick.position
	
	# Store position before clamping to detect edge collisions
	var old_position = position
	
	# clamp player movement to screen bounds
	position.x = clamp(position.x, 0, stage_width)
	if canMoveUp:
		position.y = clamp(position.y, 0, stage_height)
	elif not is_level_zero:
		position.y = clamp(position.y, 550, stage_height)
	
	# Reset velocity if player hit the screen bounds
	if old_position.x != position.x:
		# Hit left or right edge, stop horizontal momentum
		velocity.x = 0
	if old_position.y != position.y:
		# Hit top or bottom edge, stop vertical momentum
		velocity.y = 0
	
	# -- Stick logic --
	if Input.is_action_just_pressed("ui_accept") and not is_stick_pushing:
		is_stick_pushing = true
		stick_push_timer = stick_push_duration
	if is_stick_pushing:
		stick_push_timer -= delta
		if stick_push_timer < 0:
			is_stick_pushing = false
			
	# Stick position offset and flip with smooth animation
	var progress := 0.0
	if is_stick_pushing:
		# Calculate smooth progress (ease out)
		progress = 1.0 - (stick_push_timer / stick_push_duration)
		progress = ease(progress, 0.5) # Smooth easing function
	
	# Interpolate between base and extended position
	var stick_offset = stick_base_offset.lerp(stick_extended_offset, progress)
	stick_offset.x *= last_direction
	
	# Apply smooth rotation
	var stick_rotation = stick_rotation_max * progress * last_direction
	
	# Safety check for Stick node before accessing its properties
	if $Stick != null:
		$Stick.position = stick_offset
		$Stick.rotation = stick_rotation
		$Stick.scale.x = last_direction # Flip the stick sprite to face correct side
	
	# -- Puck Shooting --
	if can_shoot_puck and is_puck_cooldown_complete:
		if Input.is_action_just_pressed("shoot_puck"):
			shoot_puck()
	else:
		puck_cooldown_timer -= delta
		if puck_cooldown_timer <= 0:
			is_puck_cooldown_complete = true

# NEW THING
func _on_intro_finished():
	is_frozen = false

func apply_movement_rotation(horizontal_input: float):
	"""Apply rotation to character sprite based on horizontal movement"""
	if rotation_tween:
		rotation_tween.kill()
	
	var target_rotation: float
	if horizontal_input > 0:
		# Moving right - tilt right (positive rotation)
		target_rotation = deg_to_rad(movement_rotation_angle)
	elif horizontal_input < 0:
		# Moving left - tilt left (negative rotation)  
		target_rotation = deg_to_rad(-movement_rotation_angle)
	else:
		# Not moving horizontally - return to neutral
		target_rotation = 0.0
	
	# Smoothly tween to target rotation
	rotation_tween = create_tween()
	rotation_tween.tween_property($Sprite2D, "rotation", target_rotation, rotation_speed)

func _process(_delta):
	if is_level_zero:
		return

	if not scene_change_triggered and global_position.y <= 0:
		scene_change_triggered = true
		var current_scene_name = get_tree().current_scene.name
		if current_scene_name == "Level2":
			change_to_the_end()
		elif current_scene_name != "TheEnd":
			change_to_level_2()

func change_to_level_2():
	get_tree().change_scene_to_file("res://scenes/levels/Level2.tscn")
	
func change_to_the_end():
	get_tree().change_scene_to_file("res://scenes/TheEnd.tscn")

func heal(amount := 10.0):
	health += amount
	# Ensure health doesn't exceed max_health
	health = min(max_health, health)
	health_ui.update_health(health, max_health)

func take_damage(amount := 1.0):
	# Check if player is invincible
	if PowerUpManager and PowerUpManager.is_invincible():
		return
		
	health -= amount
	if health_ui:
		health_ui.update_health(health, max_health)
			
	# Show "Ouch!" sign
	ouch_label.visible = true
	ouch_label.modulate = Color(1, 1, 1, 1) # full opacity

	# Fade out after 2 seconds
	var tween = create_tween()
	tween.tween_property(ouch_label, "modulate:a", 0.0, 1.0).set_delay(1.0)
	tween.tween_callback(Callable(ouch_label, "hide"))
	
	# Ensure health doesn't go below 0
	health = max(0.0, health)
	health_ui.update_health(health, max_health)
	if health <= 0:
		if not is_level_zero:
			# Player is dead, show game over screen
			show_game_over()
		return # Don't play sound effects or continue damage processing if dead

	# Flash red to indicate damage (only if still alive)
	$Sprite2D.modulate = Color(1, 0, 0)
	is_invulnerable = true
	invulnerable_timer = 1.0 # seconds
	$"Audio/Pain1".play()

	# Reset modulate after a short time
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = original_modulate # back to normal (or rainbow if invincible)
	is_invulnerable = false
	invulnerable_timer = 0.0
	
func add_health(amount: int):
	health += amount
	if health_ui:
		health_ui.update_health(health, max_health)
	
func freeze():
	# Check if player is invincible
	if PowerUpManager and PowerUpManager.is_invincible():
		return
	
	is_frozen = true
	frozen_timer = 2.0 # seconds
	$Sprite2D.modulate = Color(0.5, 0.5, 1.0) # light blue
	
	# Switch background music to "Light" bus for underwater effect (has low pass filter)
	var audio = $"../audio/BossMusic"
	var original_bus = audio.bus
	audio.bus = "Light" # Switch to Light bus which has low pass filter
	
	var start_pitch = audio.pitch_scale
	if start_pitch > 0.6: # Avoid modulating music if scoop hits you after death
		var target_pitch = 0.8
		var transition_time = 0.5 # seconds for smooth transition

		# Use tween for smooth pitch transition instead of manual loop
		var pitch_tween = create_tween()
		pitch_tween.tween_property(audio, "pitch_scale", target_pitch, transition_time)
		await pitch_tween.finished
		
		# Ensure we're still valid before continuing
		if not is_inside_tree() or audio == null:
			return

		# Wait for frozen_timer duration
		await get_tree().create_timer(frozen_timer).timeout

		# Ensure we're still valid before restoring
		if not is_inside_tree() or audio == null:
			return
			
		# Smoothly restore pitch and bus
		var restore_tween = create_tween()
		restore_tween.tween_property(audio, "pitch_scale", 1.0, transition_time)
		await restore_tween.finished
		
		# Final safety check before restoring bus
		if is_inside_tree() and audio != null:
			audio.bus = original_bus # Restore original bus (Master)

	# Final safety check before restoring visual
	if is_inside_tree():
		$Sprite2D.modulate = original_modulate # back to normal (or rainbow if invincible)

func _on_invincibility_started():
	start_rainbow_effect()

func _on_invincibility_ended():
	stop_rainbow_effect()

func _on_speed_boost_started():
	start_echo_effect()

func _on_speed_boost_ended():
	stop_echo_effect()

func _on_fire_pucks_started():
	print("DEBUG: _on_fire_pucks_started signal received!")
	start_fire_stick_effect()

func _on_fire_pucks_ended():
	print("DEBUG: _on_fire_pucks_ended signal received!")
	stop_fire_stick_effect()

func start_rainbow_effect():
	# Create rainbow color cycling effect
	if rainbow_tween:
		rainbow_tween.kill()
	
	rainbow_tween = create_tween()
	rainbow_tween.set_loops() # Loop infinitely
	
	# Define rainbow colors (like Mario star power)
	var rainbow_colors = [
		Color(1.0, 0.6, 0.6, 0.6), # Light Red/Pink
		Color(1.0, 0.8, 0.4, 0.6), # Light Orange
		Color(1.0, 1.0, 0.6, 0.6), # Light Yellow
		Color(0.6, 1.0, 0.6, 0.6), # Light Green
		Color(0.6, 0.8, 1.0, 0.6), # Light Blue
		Color(0.8, 0.6, 1.0, 0.6), # Light Purple
		Color(1.0, 0.6, 1.0, 0.6) # Light Magenta
	]
	
	# Cycle through rainbow colors quickly
	for color in rainbow_colors:
		rainbow_tween.tween_property($Sprite2D, "modulate", color, 0.15)

func stop_rainbow_effect():
	# Stop rainbow effect and return to normal
	if rainbow_tween:
		rainbow_tween.kill()
		rainbow_tween = null
	
	$Sprite2D.modulate = original_modulate

	
func bounce_back_from_wall(wall_pos):
	var bounce_dir = (position - wall_pos).normalized()
	velocity = bounce_dir * 400
	
func shoot_puck():
	if not can_shoot_puck || not is_puck_cooldown_complete:
		return
	
	# Check if unlimited pucks powerup is active
	var has_unlimited = PowerUpManager and PowerUpManager.has_unlimited_pucks()
	if not has_unlimited and active_pucks >= max_active_pucks:
		return # Can't shoot if max pucks active (unless unlimited)
	
	var puck = puck_scene.instantiate()
	get_parent().add_child(puck)
	
	# Set puck position - use Stick position if available, otherwise player position
	if $Stick != null:
		puck.global_position = $Stick.global_position
	else:
		puck.global_position = self.global_position
	
	if is_level_zero:
		puck.collision_mask |= (1 << 0) # Enable bit 1 (layer 1)
	else:
		puck.collision_mask &= ~(1 << 0) # Disable bit 1 (layer 1)
	
	# Check if fire pucks powerup is active
	if PowerUpManager and PowerUpManager.has_fire_pucks():
		# 1.4x speed boost instead of setting fire mode
		if puck.has_method("set_speed_multiplier"):
			puck.set_speed_multiplier(1.4)
		elif puck.has_method("set_fire_mode"):
			# Fallback: use fire mode for visual effect if speed multiplier not available
			puck.set_fire_mode(true)
	
	active_pucks += 1
	if puck_counter:
		puck_counter.update_puck_count(max_active_pucks, active_pucks)
	
	is_puck_cooldown_complete = false
	puck_cooldown_timer = puck_cooldown # Reset cooldown timer

func _on_hitbox_body_entered(body):
	if body.is_in_group("puck") or body.is_in_group(""):
		take_damage()
		
func puck_destroyed():
	# Called when a puck is destroyed or goes out of bounds
	active_pucks = max(0, active_pucks - 1) # Ensure it never goes below 0
	if puck_counter:
		puck_counter.update_puck_count(max_active_pucks, active_pucks)
	
func show_game_over():
	# Optional: Slow down background music
	var audio = $"../audio/BossMusic"
	if audio:
		var target_pitch = 0.5
		var tween = create_tween()
		tween.tween_property(audio, "pitch_scale", target_pitch, 1.0)
		await tween.finished

	# Show the GameOver screen
	var game_over = get_parent().get_node("HUD/GameOver")
	game_over.visible = true
	game_over.process_mode = Node.PROCESS_MODE_ALWAYS # just in case

	# Give focus to the first button
	game_over.get_node("VBoxContainer/RestartLevelButton").grab_focus()

	# Optional: Pause the game to freeze other input/movement
	# get_tree().paused = true

	# Hide this player node (or just disable processing)
	visible = false
	set_process(false)
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	puck_destroyed()
	pass # Replace with function body.

func start_echo_effect():
	speed_boost_echo_active = true
	echo_timer = echo_interval # Start creating echoes immediately
	echo_color_index = 0 # Reset to start with red

func stop_echo_effect():
	speed_boost_echo_active = false
	echo_timer = 0.0
	# Clean up any remaining echo sprites
	cleanup_echo_sprites()

func create_movement_echo():
	# Only create echo if player is actually moving
	if velocity.length() < 10.0: # Don't create echo if barely moving
		return
			
	var echo = Sprite2D.new()
	echo.texture = $Sprite2D.texture
	echo.global_position = global_position
	echo.scale = $Sprite2D.scale * 1.1 # Make echoes slightly larger for visibility
	echo.rotation = $Sprite2D.rotation
	
	# Rainbow colors cycling like invincibility effect
	var rainbow_colors = [
		Color(1.0, 0.6, 0.6, 0.6), # Light Red/Pink
		Color(1.0, 0.8, 0.4, 0.6), # Light Orange
		Color(1.0, 1.0, 0.6, 0.6), # Light Yellow
		Color(0.6, 1.0, 0.6, 0.6), # Light Green
		Color(0.6, 0.8, 1.0, 0.6), # Light Blue
		Color(0.8, 0.6, 1.0, 0.6), # Light Purple
		Color(1.0, 0.6, 1.0, 0.6) # Light Magenta
	]
	
	# Use the next color in the cycle (like invincibility rainbow)
	echo.modulate = rainbow_colors[echo_color_index]
	echo_color_index = (echo_color_index + 1) % rainbow_colors.size() # Cycle to next color
	echo.z_index = 10 # Above most things but below UI (reduced from test value)
	
	# Add to parent (the scene) instead of player so it doesn't move with player
	get_parent().add_child(echo)
	echo_sprites.append(echo)
	
	
	# Immediately move the echo to its static position since it's added to the scene
	echo.global_position = global_position
	
	# Fade out the echo over time
	var fade_tween = create_tween()
	fade_tween.tween_property(echo, "modulate:a", 0.0, 1.2) # Fade over 1.2 seconds (longer)
	fade_tween.tween_callback(func(): remove_echo_sprite(echo))
	
	# Clean up old echoes if we have too many
	if echo_sprites.size() > 15: # Max 15 echoes at once (more echoes)
		var old_echo = echo_sprites.pop_front()
		if is_instance_valid(old_echo):
			old_echo.queue_free()

func remove_echo_sprite(echo_sprite: Sprite2D):
	# Remove from our tracking array and free the sprite
	if echo_sprite in echo_sprites:
		echo_sprites.erase(echo_sprite)
	if is_instance_valid(echo_sprite):
		echo_sprite.queue_free()

func cleanup_echo_sprites():
	# Clean up all remaining echo sprites
	for echo in echo_sprites:
		if is_instance_valid(echo):
			echo.queue_free()
	echo_sprites.clear()

func start_fire_stick_effect():
	print("DEBUG: start_fire_stick_effect called!")
	
	# Create fire effect on the stick
	if fire_stick_tween:
		fire_stick_tween.kill()
	
	# Create fire particle aura around the stick
	create_fire_stick_aura()
	
	# Make stick EXTREMELY red/orange with no subtlety
	var extreme_red = Color(10.0, 0.0, 0.0) # EXTREME red
	var extreme_orange = Color(10.0, 5.0, 0.0) # EXTREME orange
	
	print("DEBUG: Setting stick color to extreme red: ", extreme_red)
	$Stick/Sprite2D.modulate = extreme_red
	
	fire_stick_tween = create_tween()
	fire_stick_tween.set_loops() # Loop infinitely
	
	# Target the actual Sprite2D inside the stick, not the Area2D
	fire_stick_tween.tween_property($Stick/Sprite2D, "modulate", extreme_red, 0.2)
	fire_stick_tween.tween_property($Stick/Sprite2D, "modulate", extreme_orange, 0.2)

func stop_fire_stick_effect():
	print("DEBUG: stop_fire_stick_effect called!")
	
	# Stop fire effect and restore original stick color
	if fire_stick_tween:
		fire_stick_tween.kill()
		fire_stick_tween = null
	
	# Remove fire aura particles
	remove_fire_stick_aura()
	
	# Restore original stick sprite color
	print("DEBUG: Restoring stick color to: ", stick_original_modulate)
	$Stick/Sprite2D.modulate = stick_original_modulate

func create_fire_stick_aura():
	# Safety check - make sure we're still in the scene tree
	if not is_inside_tree():
		print("DEBUG: Player not in tree, skipping fire aura creation")
		return
	
	# Remove any existing fire aura first to prevent duplicates
	remove_fire_stick_aura()
	
	# Create particle aura around the stick for fire effect
	var fire_aura = CPUParticles2D.new()
	if fire_aura == null:
		print("ERROR: Failed to create fire aura CPUParticles2D")
		return
		
	# Add to player instead of stick to avoid rotation/scale issues
	add_child(fire_aura)
	fire_aura.name = "FireAura"
	
	# Position at stick location but don't parent to stick
	if $Stick != null:
		fire_aura.position = $Stick.position
	else:
		fire_aura.position = Vector2.ZERO # Default position if no stick
	
	# Configure fire aura
	fire_aura.emitting = true
	fire_aura.amount = 40
	fire_aura.lifetime = 1.5
	fire_aura.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	fire_aura.emission_sphere_radius = 25.0 # Larger radius
	
	# Aura should emanate outward in all directions
	fire_aura.direction = Vector2(0, -1)
	fire_aura.spread = 180.0 # Full circle
	
	# Slow particles for aura effect
	fire_aura.initial_velocity_min = 30.0
	fire_aura.initial_velocity_max = 80.0
	
	# Massive fire aura particles - 5x larger
	fire_aura.scale_amount_min = 7.5
	fire_aura.scale_amount_max = 15.0
	
	# Make particles FULLY OPAQUE and very bright
	fire_aura.color = Color(3.0, 1.0, 0.0, 1.0) # Bright orange, fully opaque
	
	# Remove gradient for now to test visibility
	# fire_aura.color_ramp = create_fire_aura_gradient()
	
	# No gravity for floating aura effect
	fire_aura.gravity = Vector2.ZERO
	
	# Higher z-index to render on top
	fire_aura.z_index = 100
	
	print("DEBUG: Fire aura created with ", fire_aura.amount, " particles at position ", fire_aura.position)

func create_fire_aura_gradient() -> Gradient:
	var gradient = Gradient.new()
	
	# Start bright
	gradient.add_point(0.0, Color(2.0, 1.0, 0.3, 1.0)) # Bright yellow
	# Mid-way orange
	gradient.add_point(0.5, Color(2.0, 0.5, 0.0, 0.6)) # Orange
	# End transparent red
	gradient.add_point(1.0, Color(1.5, 0.0, 0.0, 0.0)) # Transparent red
	
	return gradient

func remove_fire_stick_aura():
	# Remove ALL fire aura particles to prevent any from lingering
	var removed_count = 0
	
	# Check for any fire aura nodes and remove them all
	for child in get_children():
		if child.name == "FireAura" and child is CPUParticles2D:
			print("DEBUG: Removing FireAura node")
			child.emitting = false # Stop creating new particles
			child.amount = 0 # Clear existing particles
			child.call_deferred("queue_free")
			removed_count += 1
	
	if removed_count > 0:
		print("DEBUG: Removed ", removed_count, " FireAura node(s)")
	else:
		print("DEBUG: No FireAura nodes found to remove")
