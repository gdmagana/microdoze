extends StaticBody2D

@export var health := 1

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D):
	if body.is_in_group("balls"):
		_on_ball_hit(body)

func _on_ball_hit(ball: Node2D):
	if ball.canBreak:
		health -= 1
		if health <= 0:
			ball.linear_velocity.y = -abs(ball.linear_velocity.y)
			ball.linear_velocity = ball.linear_velocity * 1.5
			
			queue_free()
