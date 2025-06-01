extends RigidBody2D

@export var canBreak := true

@export var initial_speed := 300.0
@export var min_speed := 100.0
@export var max_speed := 800.0 # Maximum allowed speed
@export var max_lateral_speed := 400.0
@export var min_lateral_speed := 80.0
@export var lateral_damp := 0.98
@onready var speed := initial_speed

# Fire mode properties
var is_fire_mode := false
var fire_damage_multiplier := 2.0

func _ready():
	add_to_group("puck")
	gravity_scale = 0
	# Launch in a random direction
	var angle = randf_range(-PI / 4, -3 * PI / 4) # upward
	linear_velocity = Vector2(cos(angle), sin(angle)) * initial_speed
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_screen_exited"))

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

func get_damage_amount() -> int:
	return fire_damage_multiplier if is_fire_mode else 1

func _on_body_entered(body):
	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(get_damage_amount())
			
		# Bounce off the boss by reflecting the velocity
		var collision_normal = (global_position - body.global_position).normalized()
		linear_velocity = linear_velocity.bounce(collision_normal).normalized() * speed
		

func accelerate(multiplier: float):
	# Update the ball's speed with the multiplier
	speed = min(speed * multiplier, max_speed)
	$"../audio/Yay1".play()
	# Immediately apply the new speed while maintaining direction
	linear_velocity = linear_velocity.normalized() * speed
	
	# Turn the puck red briefly to indicate acceleration
	flash_red()
	
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

func _on_screen_exited():
	destroy_puck()
