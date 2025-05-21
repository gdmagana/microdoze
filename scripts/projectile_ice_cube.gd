extends Area2D

var velocity = Vector2.ZERO

func _process(delta):
	position += velocity * delta
