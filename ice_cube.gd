extends StaticBody2D

@export var health := 1

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("balls"):
		_on_ball_hit()

func _on_ball_hit():
	health -= 1
	if health <= 0:
		queue_free()
