extends CharacterBody2D

@onready var health_ui = get_tree().get_current_scene().get_node("HUD/HealthUI")
@onready var puck_counter = get_tree().get_current_scene().get_node("HUD/PuckCounter")

# -- Player Health --
@export var health := 3

# -- Player Movement --
@export var acceleration := 800.0
@export var friction := 600.0
@export var max_speed := 500.0

var is_frozen := false
var frozen_timer := 0.0
var can_move_up := false

var is_invulnerable := false
var invulnerable_timer := 0.0

# -- Stick --
var last_direction := 1 # 1 = right, -1 = left
var stick_push_timer := 0.0
var stick_push_duration := 0.15 # seconds
var is_stick_pushing := false
var stick_base_offset := Vector2(50, 0)
var stick_extended_offset := Vector2(50, -25)
var stick_rotation_max := -0.5 # Maximum rotation in radians

# -- Puck --
@export var puck_scene: PackedScene
@export var puck_speed := 700.0
@export var max_active_pucks := 5 # Maximum number of active pucks allowed
@export var puck_cooldown := 0.5 # Time in seconds between puck shots
var active_pucks := 0 # Current number of active pucks
var puck_cooldown_timer := 0.0 # Timer for puck shooting cooldown
var can_shoot_puck = true

# -- Stage Bounds --
var stage_width
var stage_height

func _ready():
	add_to_group("player")
	$Stick.add_to_group("player_stick")
	
	stage_width = get_viewport_rect().size.x
	stage_height = get_viewport_rect().size.y
	
	health_ui.update_health(health)
	if puck_counter:
		puck_counter.update_puck_count(max_active_pucks, active_pucks)
	$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

func take_damage(amount := 1):
	health -= amount
	health_ui.update_health(health)
	if health <= 0:
		# Player is dead, show game over screen
		show_game_over()
		
	else:
		# Flash red to indicate damage
		$Sprite2D.modulate = Color(1, 0.5, 0.5)
		is_invulnerable = true
		invulnerable_timer = 1.0 # seconds
		$"../audio/Pain1".play()

		# Reset modulate after a short time
		await get_tree().create_timer(0.2).timeout
		$Sprite2D.modulate = Color(1, 1, 1) # back to normal
		is_invulnerable = false
		invulnerable_timer = 0.0
	
func freeze():
	is_frozen = true
	frozen_timer = 2.0 # seconds
	$Sprite2D.modulate = Color(0.5, 0.5, 1.0) # light blue
	# Smoothly slow down the background music, then restore it
	var audio = $"../audio/BossMusic"
	var start_pitch = audio.pitch_scale
	if start_pitch > 0.6: # Avoid modulating music if scoop hits you after death
		var target_pitch = 0.8
		var transition_time = 0.5 # seconds for smooth transition

		# Smoothly decrease pitch
		var t := 0.0
		while t < transition_time:
			t += get_process_delta_time()
			audio.pitch_scale = lerp(start_pitch, target_pitch, t / transition_time)
			await get_tree().process_frame # TODO: fix crash when this occurs during game end
		audio.pitch_scale = target_pitch

		# Wait for frozen_timer duration
		await get_tree().create_timer(frozen_timer).timeout

		# Smoothly restore pitch
		t = 0.0
		while t < transition_time:
			t += get_process_delta_time()
			audio.pitch_scale = lerp(target_pitch, 1.0, t / transition_time)
			await get_tree().process_frame
		audio.pitch_scale = 1.0 # reset pitch

	$Sprite2D.modulate = Color(1, 1, 1) # back to normal

	
func bounce_back_from_wall(wall_pos):
	var bounce_dir = (position - wall_pos).normalized()
	velocity = bounce_dir * 400
	
func enable_vertical_movement():
	can_move_up = true
	
func enable_puck_shooting():
	can_shoot_puck = true
	
func disable_puck_shooting():
	can_shoot_puck = false
	
func shoot_puck():
	if not can_shoot_puck or active_pucks >= max_active_pucks:
		return # Can't shoot if puck shooting is disabled or max pucks active
	
	var puck = puck_scene.instantiate()
	get_parent().add_child(puck)
	puck.global_position = $Stick.global_position
	
	active_pucks += 1
	if puck_counter:
		puck_counter.update_puck_count(max_active_pucks, active_pucks)
	
	can_shoot_puck = false
	puck_cooldown_timer = puck_cooldown # Reset cooldown timer

func _physics_process(delta):
	if is_frozen:
		frozen_timer -= delta
		if frozen_timer <= 0:
			is_frozen = false
			$Sprite2D.modulate = Color(1, 1, 1) # back to normal
		return # skip movement while frozen
		
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if can_move_up:
		if Input.is_action_pressed("ui_up"):
			input_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			input_direction.y += 1

	# -- Movement Physics --
	# Horizontal
	if input_direction.x != 0:
		last_direction = sign(input_direction.x)
		velocity.x += input_direction.x * acceleration * delta
	else:
		# Apply friction to gradually stop
		if abs(velocity.x) < friction * delta:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * friction * delta
			
	# clamp max horizontal speed
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	# Vertical
	if can_move_up:
		if input_direction.y != 0:
			velocity.y += input_direction.y * acceleration * delta
		else:
			if abs(velocity.y) < friction * delta:
				velocity.y = 0
			else:
				velocity.y -= sign(velocity.y) * friction * delta
				
			velocity.y = clamp(velocity.y, -max_speed, max_speed)
	else:
		velocity.y = 0

	move_and_slide()
	
	# Store position before clamping to detect edge collisions
	var old_position = position
	
	# clamp player movement to screen bounds
	position.x = clamp(position.x, 0, stage_width)
	position.y = clamp(position.y, 0, stage_height)
	
	# Reset velocity if player hit the screen bounds
	if old_position.x != position.x:
		# Hit left or right edge, stop horizontal momentum
		velocity.x = 0
	if old_position.y != position.y:
		# Hit top or bottom edge, stop vertical momentum
		velocity.y = 0
	
	# -- Player Hitbox --
	var hitbox = $CollisionShape2D.shape
	# Radius is available if needed: var hitbox_radius = hitbox.radius
	
	# -- Stick logic --
	if Input.is_action_just_pressed("ui_accept") and not is_stick_pushing:
		is_stick_pushing = true
		stick_push_timer = stick_push_duration
	# also use up arrow if user cant move up
	elif Input.is_action_just_pressed("ui_up") and not can_move_up and not is_stick_pushing:
		is_stick_pushing = true
		stick_push_timer = stick_push_duration
		# in this case, also try shooting puck
		shoot_puck()
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
	
	$Stick.position = stick_offset
	$Stick.rotation = stick_rotation
	$Stick.scale.x = last_direction # Flip the stick sprite to face correct side
	
	# -- Puck Shooting --
	if not can_shoot_puck:
		puck_cooldown_timer -= delta
		if puck_cooldown_timer <= 0:
			can_shoot_puck = true # Re-enable puck shooting after cooldown
	else:
		# Check if the player is trying to shoot a puck
		if Input.is_action_just_pressed("shoot_puck"):
			shoot_puck()

func _on_hitbox_body_entered(body):
	if body.is_in_group("puck") or body.is_in_group(""):
		take_damage()
		
func puck_destroyed():
	# Called when a puck is destroyed or goes out of bounds
	active_pucks = max(0, active_pucks - 1) # Ensure it never goes below 0
	if puck_counter:
		puck_counter.update_puck_count(max_active_pucks, active_pucks)
	
func show_game_over():
	# Slow down background music
	var audio = $"../audio/BossMusic"
	if audio:
		var target_pitch = 0.5 # Slow to half speed
		
		# Immediately set half speed if we can't do smooth transition
		if not is_inside_tree() or get_tree() == null:
			audio.pitch_scale = target_pitch
		else:
			# Try to create a smooth transition for music slowdown
			var transition_time = 1.0 # seconds for smooth transition
			var tween = create_tween()
			tween.tween_property(audio, "pitch_scale", target_pitch, transition_time)
			# Wait for the tween to finish
			await tween.finished
	
	# Make sure we're still valid before continuing
	if not is_inside_tree():
		return
		
	# Create and display the game over screen
	var game_over_scene = load("res://scenes/GameOver.tscn")
	var game_over_instance = game_over_scene.instantiate()
	get_tree().get_current_scene().add_child(game_over_instance)
	
	# Don't remove player yet - let the game over screen handle restarting
	visible = false # Hide the player
	set_process(false)
	set_physics_process(false)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	puck_destroyed()
	pass # Replace with function body.
