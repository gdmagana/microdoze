extends RigidBody2D

@export var canBreak := false

@export var initial_speed := 300.0
@export var min_speed := 100.0
@export var max_lateral_speed := 400.0
@export var min_lateral_speed := 80.0
@export var lateral_damp := 0.98
@onready var speed := initial_speed

func _ready():
	add_to_group("balls")
	gravity_scale = 0
	# Launch in a random direction
	var angle = randf_range(-PI / 4, -3 * PI / 4)  # upward
	linear_velocity = Vector2(cos(angle), sin(angle)) * initial_speed

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
