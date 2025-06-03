extends Area2D

var velocity := Vector2.ZERO
var canHurtBoss := false
var is_static_wall := false
var health := 3

# Powerup system integration
@export var powerup_scene: PackedScene # Optional powerup to drop
@export var powerup_drop_chance: float = 0.0 # 0.0 = never, 1.0 = always

# Powerup preview sprite (will be created dynamically)
var powerup_preview_sprite: Sprite2D

# Preload the textures for different health states
var texture_normal = preload("res://assets/sprites/ice_cube_weak.png")
var texture_blue = preload("res://assets/sprites/ice_cube_fresh.png")
var texture_damaged = preload("res://assets/sprites/ice_cube_weaker.png")

func _ready():
	add_to_group("ice_cube")
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Set the initial texture
	update_sprite_based_on_health()
	# Create powerup preview sprite
	create_powerup_preview_sprite()

func create_powerup_preview_sprite():
	# Create a sprite for showing powerup preview
	powerup_preview_sprite = Sprite2D.new()
	powerup_preview_sprite.name = "PowerupPreview"
	powerup_preview_sprite.scale = Vector2(0.1, 0.1) # Larger size for better visibility
	powerup_preview_sprite.position = Vector2(0, -40) # Position above the ice cube
	powerup_preview_sprite.visible = false # Hidden by default
	powerup_preview_sprite.z_index = 10 # Render on top of everything
	add_child(powerup_preview_sprite)

func _process(delta):
	if not is_static_wall:
		position += velocity * delta
		
		# free if off screen
		var viewport_rect := get_viewport_rect()
		if not viewport_rect.has_point(global_position):
			queue_free()

func update_sprite_based_on_health():
	# Change the sprite based on health
	if health <= 1:
		$Sprite2D.texture = texture_damaged
	else:
		if health >= 3:
			$Sprite2D.texture = texture_blue
		else:
			$Sprite2D.texture = texture_normal

func _on_body_entered(body):
	# pucks break or bounce off ice:
	if body.is_in_group("puck"):
		# Decrease health
		health -= 1
		
		# Update the sprite based on new health
		update_sprite_based_on_health()
		
		# Bounce the puck regardless of health
		if "linear_velocity" in body:
			# Calculate bounce direction
			var bounce_direction = (body.global_position - global_position).normalized()
			body.linear_velocity = body.linear_velocity.bounce(bounce_direction)
		
		# Only destroy if health is depleted
		if health <= 0:
			# Drop powerup before destroying
			drop_powerup()
			queue_free()
	# if the ice cube hits the player, hurt them
	if body.is_in_group("player"):
		if not is_static_wall:
			body.take_damage()
			# Drop powerup before destroying
			drop_powerup()
			queue_free()
		else:
			body.take_damage()
			body.bounce_back_from_wall(global_position)
	## if the ice cube is hit by the stick, be hit back
	#if body.is_in_group("player_stick"):
		#canHurtBoss = true
		#velocity = -velocity
	## if the ice cube hits the boss, hurt them
	#if body.is_in_group("boss"):
		#if canHurtBoss:
			#body.take_damage()
			#queue_free()

func drop_powerup():
	if powerup_scene and randf() <= powerup_drop_chance:
		var powerup = powerup_scene.instantiate()
		get_parent().add_child(powerup)
		powerup.global_position = global_position
		print("Powerup dropped at: ", global_position)

# Method to set powerup (useful for boss or other systems)
func set_powerup(scene: PackedScene, drop_chance: float = 1.0):
	powerup_scene = scene
	powerup_drop_chance = drop_chance
	
	# Show powerup preview
	if powerup_scene:
		show_powerup_preview()

func show_powerup_preview():
	if not powerup_preview_sprite or not powerup_scene:
		return
		
	# Instantiate the powerup temporarily to get its appearance
	var temp_powerup = powerup_scene.instantiate()
	
	# Find the sprite in the powerup to get its texture and color
	var powerup_sprite = temp_powerup.get_node("Sprite2D")
	if powerup_sprite:
		# Copy the texture and modulation from the powerup
		powerup_preview_sprite.texture = powerup_sprite.texture
		powerup_preview_sprite.modulate = powerup_sprite.modulate
		powerup_preview_sprite.visible = true
		
		# Make ice cube semi-transparent to show it contains a powerup
		$Sprite2D.modulate.a = 0.8
		
		# Add a subtle pulsing effect to make it more noticeable
		create_powerup_pulse_effect()
	
	# Clean up the temporary powerup
	temp_powerup.queue_free()

func create_powerup_pulse_effect():
	if not powerup_preview_sprite:
		return
		
	var tween = create_tween()
	tween.set_loops() # Loop infinitely
	tween.tween_property(powerup_preview_sprite, "scale", Vector2(0.08, 0.08), 0.8) # Shrink
	tween.tween_property(powerup_preview_sprite, "scale", Vector2(0.1, 0.1), 0.8) # Grow back

func set_as_static_wall():
	is_static_wall = true
	velocity = Vector2.ZERO
