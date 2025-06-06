extends RigidBody2D

@export var canBreak := true

@export var initial_speed := 300.0
@export var min_speed := 100.0
@export var max_speed := 750.0 # Maximum allowed speed (2.5x base speed)
@export var max_lateral_speed := 400.0
@export var min_lateral_speed := 80.0
@export var lateral_damp := 0.98
@onready var speed := initial_speed

# Fire mode properties
var is_fire_mode := false
var fire_damage_multiplier := 2.0
var speed_multiplier := 1.0 # For fire pucks speed boost

# Particle trail system for fire boost
var particle_trail: CPUParticles2D
var has_fire_boost := false

func _ready():
	add_to_group("puck")
	gravity_scale = 0
	# Launch in a random direction
	var angle = randf_range(-PI / 4, -3 * PI / 4) # upward
	var launch_speed = initial_speed * speed_multiplier # Apply speed multiplier
	linear_velocity = Vector2(cos(angle), sin(angle)) * launch_speed
	speed = launch_speed # Update the speed variable too
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_screen_exited"))
	
	# Check if this puck should have fire boost particle trail
	if PowerUpManager and PowerUpManager.has_fire_pucks():
		has_fire_boost = true
		create_fire_particle_trail()

func set_fire_mode(enabled: bool):
	is_fire_mode = enabled
	if is_fire_mode:
		# Visual effect for fire mode - make it orange/red with a slight glow
		$Sprite2D.modulate = Color(1.0, 0.5, 0.0) # Orange
		# Optional: Add a pulsing effect
		start_fire_pulse_effect()
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0) # Normal white

func start_fire_pulse_effect():
	if not is_fire_mode:
		return
		
	var tween = create_tween()
	tween.set_loops() # Loop infinitely
	tween.tween_property($Sprite2D, "modulate", Color(1.0, 0.3, 0.0), 0.3) # Darker orange
	tween.tween_property($Sprite2D, "modulate", Color(1.0, 0.7, 0.0), 0.3) # Brighter orange

func get_damage_amount() -> float:
	return fire_damage_multiplier if is_fire_mode else 1.0

func _on_body_entered(body):
	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(get_damage_amount())
			
		# Bounce off the boss by reflecting the velocity
		var collision_normal = (global_position - body.global_position).normalized()
		linear_velocity = linear_velocity.bounce(collision_normal).normalized() * speed
		

func accelerate(multiplier: float):
	# Check if fire pucks powerup is active for additional speed boost
	var fire_boost = 1.0
	if PowerUpManager and PowerUpManager.has_fire_pucks():
		fire_boost = 1.4
	
	# Update the ball's speed with the multiplier and fire boost
	var total_multiplier = multiplier * fire_boost
	speed = min(speed * total_multiplier, max_speed)
	$"Audio/Yay1".play()
	
	# Immediately apply the new speed while maintaining direction
	linear_velocity = linear_velocity.normalized() * speed
	
	# Apply permanent fire effects if hit by fire stick
	if fire_boost > 1.0:
		has_fire_boost = true
		set_fire_mode(true)
		# Only create trail if we don't already have one
		if not particle_trail:
			create_fire_particle_trail()
		flash_orange() # Fire effect
	else:
		flash_red() # Normal acceleration

func destroy_puck():
	# Notify player to remove a puck from the active count
	var player = get_tree().get_current_scene().find_child("Player", true, false)
	if player and player.has_method("puck_destroyed"):
		player.puck_destroyed()
	queue_free()
	

func flash_red():
	var original_modulate = self.modulate
	self.modulate = Color(1, 0, 0) # Red
	await get_tree().create_timer(0.3).timeout
	self.modulate = original_modulate

func flash_orange():
	var original_modulate = self.modulate
	self.modulate = Color(1.0, 0.6, 0.0) # Orange fire color
	await get_tree().create_timer(0.3).timeout
	self.modulate = original_modulate

func _physics_process(_delta):
	# Enforce minimum vertical speed only
	if abs(linear_velocity.y) < min_speed:
		linear_velocity.y = sign(linear_velocity.y) * min_speed

	# Dampen lateral (x) velocity toward min_lateral_speed
	if abs(linear_velocity.x) > min_lateral_speed:
		linear_velocity.x *= lateral_damp
		if abs(linear_velocity.x) < min_lateral_speed:
			linear_velocity.x = sign(linear_velocity.x) * min_lateral_speed
	# Clamp to max_lateral_speed
	linear_velocity.x = clamp(linear_velocity.x, -max_lateral_speed, max_lateral_speed)

	# Always keep the total velocity normalized to the current speed
	linear_velocity = linear_velocity.normalized() * max(speed, min_speed)
	
	# Update particle trail direction to opposite of movement for trailing effect
	if has_fire_boost and particle_trail and is_instance_valid(particle_trail):
		particle_trail.direction = - linear_velocity.normalized()

func _on_screen_exited():
	destroy_puck()

func set_speed_multiplier(multiplier: float):
	speed_multiplier = multiplier
	# If already launched, apply speed boost immediately
	if linear_velocity.length() > 0:
		speed *= multiplier
		linear_velocity = linear_velocity.normalized() * speed
	
	# Apply fire visual effects and trail for speed boosted pucks
	if multiplier > 1.0:
		has_fire_boost = true
		set_fire_mode(true)
		create_fire_particle_trail()

func create_fire_particle_trail():
	# Don't create multiple trails
	if particle_trail:
		return
	
	# Safety check - make sure we're still in the scene tree
	if not is_inside_tree():
		print("DEBUG: Ball not in tree, skipping particle trail creation")
		return
		
	# Create particle trail for fire-boosted pucks
	particle_trail = CPUParticles2D.new()
	if particle_trail == null:
		print("ERROR: Failed to create CPUParticles2D")
		return
		
	add_child(particle_trail)
	
	# Configure particle trail
	particle_trail.emitting = true
	particle_trail.amount = 30
	particle_trail.lifetime = 1.2
	particle_trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particle_trail.emission_sphere_radius = 8.0
	
	# Direction - particles should trail behind the puck
	particle_trail.direction = Vector2(0, 1) # Will be updated in _process
	particle_trail.spread = 30.0
	
	# Velocity - slower than puck so they trail behind
	particle_trail.initial_velocity_min = 50.0
	particle_trail.initial_velocity_max = 100.0
	
	# Make particles 5x larger for dramatic fire effect
	particle_trail.scale_amount_min = 5.0
	particle_trail.scale_amount_max = 12.5
	
	# Fire colors - red, orange, yellow
	var fire_colors = [
		Color(1.0, 0.0, 0.0, 1.0), # Red
		Color(1.0, 0.5, 0.0, 1.0), # Orange
		Color(1.0, 0.8, 0.0, 1.0), # Yellow-orange
		Color(1.0, 1.0, 0.2, 1.0), # Yellow
	]
	
	# Set random fire color
	particle_trail.color = fire_colors[randi() % fire_colors.size()]
	
	# Create fire gradient that fades to transparent
	particle_trail.color_ramp = create_fire_gradient()
	
	# No gravity for power trail effect
	particle_trail.gravity = Vector2.ZERO

func create_fire_gradient() -> Gradient:
	var gradient = Gradient.new()
	
	# Start bright fire color
	gradient.add_point(0.0, Color(1.0, 0.8, 0.2, 1.0)) # Bright yellow-orange
	# Mid-way orange-red
	gradient.add_point(0.5, Color(1.0, 0.3, 0.0, 0.8)) # Orange-red
	# End transparent red
	gradient.add_point(1.0, Color(0.8, 0.0, 0.0, 0.0)) # Transparent red
	
	return gradient
