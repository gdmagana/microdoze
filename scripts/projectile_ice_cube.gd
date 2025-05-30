extends Area2D

var velocity := Vector2.ZERO
var canHurtBoss := false
var is_static_wall := false
var health := 3

# Preload the textures for different health states
var texture_normal = preload("res://assets/sprites/ice_cube.png")
var texture_blue = preload("res://assets/sprites/ice_cube_blue.png")
var texture_damaged = preload("res://assets/sprites/ice_cube_weak.png")

func _ready():
	add_to_group("ice_cube")
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Set the initial texture
	update_sprite_based_on_health()

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
			queue_free()
	# if the ice cube hits the player, hurt them
	if body.is_in_group("player"): 
		if not is_static_wall:
			body.take_damage()
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

func set_as_static_wall():
	is_static_wall = true
	velocity = Vector2.ZERO
