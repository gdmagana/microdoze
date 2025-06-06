extends Area2D

@export var hit_acceleration := 1.2  # Multiplier for ball speed when hit

func _ready():
	connect("body_shape_entered", Callable(self, "_on_body_shape_entered"))

func _on_body_shape_entered(_body_id, body, _body_shape_index, _local_shape_index):
	if body.is_in_group("puck"):
		# Accelerate the ball
		body.accelerate(hit_acceleration)
		
		# Bounce the ball upward while maintaining horizontal momentum
		body.linear_velocity.y = -abs(body.linear_velocity.y)
		
		# Allow the ball to break ice cubes after being hit
		body.canBreak = true
		
