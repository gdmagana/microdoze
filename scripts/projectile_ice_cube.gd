extends Area2D

var velocity = Vector2.ZERO
var canHurtBoss = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	position += velocity * delta

func _on_body_entered(body):
	# if the ice cube hits the player, hurt them
	if body.is_in_group("player"):
		body.take_damage()
		queue_free()

func _on_area_entered(area):
	# if the ice cube is hit by the stick, be hit back
	if area.is_in_group("player_stick"):
		canHurtBoss = true
		velocity = -velocity
	elif area.is_in_group("boss"):
		if canHurtBoss:
			area.take_damage()
			queue_free()
