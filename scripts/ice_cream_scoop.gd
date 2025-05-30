extends Area2D

@export var speed = 400
var velocity = Vector2.ZERO

func _ready():
	add_to_group("ice_cream_scoops") # not sure if i need this
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
	position += velocity * delta

func _on_body_entered(body):
	# if the ice cube hits the player, hurt them
	if body.is_in_group("player"):
		body.freeze()
		queue_free()
