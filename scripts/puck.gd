extends Area2D

var velocity := Vector2.ZERO

func _ready():
	add_to_group("puck")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position += velocity * delta
