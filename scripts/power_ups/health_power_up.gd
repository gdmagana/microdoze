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
		create_rainbow_particle_burst(player.global_position)

func create_rainbow_particle_burst(position: Vector2):
	var particle_system = CPUParticles2D.new()
	get_parent().add_child(particle_system)
	particle_system.global_position = position

	particle_system.emitting = true
	particle_system.amount = 50
	particle_system.lifetime = 2.0
	particle_system.one_shot = true

	particle_system.explosiveness = 1.0
	particle_system.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particle_system.emission_sphere_radius = 20.0

	particle_system.direction = Vector2(0, -1)
	particle_system.spread = 180.0

	particle_system.initial_velocity_min = 150.0
	particle_system.initial_velocity_max = 300.0

	particle_system.angular_velocity_min = -360.0
	particle_system.angular_velocity_max = 360.0

	particle_system.gravity = Vector2(0, 200)
	particle_system.linear_accel_min = -50.0
	particle_system.linear_accel_max = -50.0

	particle_system.scale_amount_min = 4
	particle_system.scale_amount_max = 7.5

	# Set color to white so initial ramp is not tinted
	particle_system.color = Color(1, 1, 1, 1)

	# Assign a sharp rainbow gradient to color_initial_ramp
	particle_system.color_initial_ramp = create_neon_rainbow_sharp_gradient()

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

func create_neon_rainbow_sharp_gradient() -> Gradient:
	var gradient = Gradient.new()
	# Each color stop is close together for sharp transitions
	gradient.add_point(0.00, Color(1.0, 0.07, 0.57, 1.0))  # Neon pink
	gradient.add_point(0.14, Color(1.0, 0.0, 0.0, 1.0))    # Neon red
	gradient.add_point(0.28, Color(1.0, 1.0, 0.0, 1.0))    # Neon yellow
	gradient.add_point(0.42, Color(0.0, 1.0, 0.2, 1.0))    # Neon green
	gradient.add_point(0.57, Color(0.0, 1.0, 1.0, 1.0))    # Neon cyan
	gradient.add_point(0.71, Color(0.0, 0.4, 1.0, 1.0))    # Neon blue
	gradient.add_point(0.85, Color(0.6, 0.0, 1.0, 1.0))    # Neon purple
	gradient.add_point(1.00, Color(1.0, 0.07, 0.57, 1.0))  # Loop back to neon pink
	return gradient
