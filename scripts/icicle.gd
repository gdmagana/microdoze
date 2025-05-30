extends Area2D

var velocity = Vector2.ZERO
var canHurtBoss = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
	position += velocity * delta

func _on_body_entered(body):
	# if the ice cube hits the player, hurt them
	if body.is_in_group("player"):
		body.take_damage()
		queue_free()
