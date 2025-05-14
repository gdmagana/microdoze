extends Area2D

func _ready():
	connect("body_shape_entered", Callable(self, "_on_body_shape_entered"))

func _on_body_shape_entered(body_id, body, body_shape_index, local_shape_index):
	if body.is_in_group("balls"):
		# Example: bounce the ball upward and add a little lateral push
		body.linear_velocity.y = -abs(body.linear_velocity.y)
		# Optionally add some x velocity if you want
		# body.linear_velocity.x += 100 * sign(body.position.x - position.x)
		
		# for now, the player must hit a ball with their stick in order for the
		# ball to break the ice cube (as opposed to a ball breaking an ice cube
		# with no help from the player)
		body.canBreak = true
