extends StaticBody2D

@export var health := 2
@export var powerup_scene: PackedScene # Optional powerup to drop
@export var powerup_drop_chance: float = 1.0 # 0.0 = never, 1.0 = always

# Powerup preview sprite (will be created dynamically)
var powerup_preview_sprite: Sprite2D

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	# Create powerup preview sprite
	create_powerup_preview_sprite()

func create_powerup_preview_sprite():
	# Create a sprite for showing powerup preview
	powerup_preview_sprite = Sprite2D.new()
	powerup_preview_sprite.name = "PowerupPreview"
	powerup_preview_sprite.scale = Vector2(0.08, 0.08) # Larger size for better visibility
	powerup_preview_sprite.position = Vector2(0, -50) # Position above the ice cube
	powerup_preview_sprite.visible = false # Hidden by default
	powerup_preview_sprite.z_index = 10 # Render on top of everything
	add_child(powerup_preview_sprite)

func _on_body_entered(body: Node2D):
	if body.is_in_group("puck"):
		_on_ball_hit(body)

func _on_ball_hit(ball: Node2D):
	if ball.canBreak:
		health -= 1
		if health <= 0:
			ball.linear_velocity.y = - abs(ball.linear_velocity.y)
			ball.linear_velocity = ball.linear_velocity * 1.5
			
			# Drop powerup if available and chance succeeds
			drop_powerup()
			
			queue_free()

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
	tween.tween_property(powerup_preview_sprite, "scale", Vector2(0.06, 0.06), 0.8) # Shrink
	tween.tween_property(powerup_preview_sprite, "scale", Vector2(0.08, 0.08), 0.8) # Grow back
