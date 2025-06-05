extends BasePowerUp
class_name HealthPowerUp

@export var health_amount: float = 20.0

func _ready():
	super._ready()
	powerup_type = "health"

func activate_effect():
	# Find the player and heal them
	var player = get_tree().get_current_scene().find_child("Player", true, false)
	if player and player.has_method("heal"):
		player.heal(health_amount)
		
		# Create green particle burst around the player
		create_green_particle_burst(player.global_position)

func create_green_particle_burst(position: Vector2):
	# Create a temporary node to hold the particle system
	var particle_system = CPUParticles2D.new()
	get_parent().add_child(particle_system)
	particle_system.global_position = position
	
	# Configure the particle system for green confetti burst
	particle_system.emitting = true
	particle_system.amount = 50
	particle_system.lifetime = 2.0
	particle_system.one_shot = true
	
	# Emission properties
	particle_system.explosiveness = 1.0 # All particles at once for burst effect
	particle_system.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particle_system.emission_sphere_radius = 20.0
	
	# Direction and spread
	particle_system.direction = Vector2(0, -1) # Upward base direction
	particle_system.spread = 180.0 # Full 360-degree spread for confetti effect
	
	# Velocity
	particle_system.initial_velocity_min = 150.0
	particle_system.initial_velocity_max = 300.0
	
	# Angular velocity for spinning confetti effect
	particle_system.angular_velocity_min = -360.0
	particle_system.angular_velocity_max = 360.0
	
	# Gravity to make particles fall like confetti
	particle_system.gravity = Vector2(0, 200)
	
	# Damping to slow particles over time
	particle_system.linear_accel_min = -50.0
	particle_system.linear_accel_max = -50.0
	
	# Scale for confetti pieces
	particle_system.scale_amount_min = 4
	particle_system.scale_amount_max = 7.5
	
	# Colors - various shades of green
	var green_colors = [
		Color(0.0, 1.0, 0.0, 1.0), # Bright green
		Color(0.0, 0.8, 0.2, 1.0), # Forest green
		Color(0.2, 1.0, 0.3, 1.0), # Light green
		Color(0.0, 0.6, 0.0, 1.0), # Dark green
		Color(0.4, 1.0, 0.4, 1.0), # Pale green
	]
	
	# Set random green color
	var random_color = green_colors[randi() % green_colors.size()]
	particle_system.color = random_color
	
	# Color variation for more dynamic effect
	particle_system.color_ramp = create_green_color_gradient()
	
	# Remove particle system after particles finish
	var cleanup_timer = Timer.new()
	get_parent().add_child(cleanup_timer)
	cleanup_timer.wait_time = particle_system.lifetime + 1.0
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(particle_system):
			particle_system.queue_free()
		cleanup_timer.queue_free()
	)
	cleanup_timer.start()

func create_green_color_gradient() -> Gradient:
	# Create a gradient that fades green particles from bright to transparent
	var gradient = Gradient.new()
	
	# Start bright green
	gradient.add_point(0.0, Color(0.2, 1.0, 0.3, 1.0))
	# Mid-way slightly darker
	gradient.add_point(0.5, Color(0.0, 0.8, 0.2, 0.8))
	# End transparent
	gradient.add_point(1.0, Color(0.0, 0.6, 0.0, 0.0))
	
	return gradient
