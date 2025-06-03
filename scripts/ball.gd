extends RigidBody2D

@export var canBreak := true

@export var initial_speed := 300.0
@export var min_speed := 100.0
@export var max_speed := 800.0  # Maximum allowed speed
@export var max_lateral_speed := 400.0
@export var min_lateral_speed := 80.0
@export var lateral_damp := 0.98
@onready var speed := initial_speed

func _ready():
	add_to_group("puck")
	gravity_scale = 0
	# Launch in a random direction
	var angle = randf_range(-PI / 4, -3 * PI / 4)  # upward
	linear_velocity = Vector2(cos(angle), sin(angle)) * initial_speed
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_screen_exited"))

func _on_body_entered(body):
	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage()
			
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

func flash_red():
	var original_modulate = self.modulate
	self.modulate = Color(1, 0, 0)  # Red
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
	# Notify the player that this puck is being destroyed
	var player = get_tree().get_current_scene().find_child("Player", true, false)
	if player and player.has_method("puck_destroyed"):
		player.puck_destroyed()
	queue_free()
