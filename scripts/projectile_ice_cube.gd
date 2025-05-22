extends Area2D

var velocity := Vector2.ZERO
var canHurtBoss := false
var is_static_wall := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	if not is_static_wall:
		position += velocity * delta
		
		# free if off screen
		var viewport_rect := get_viewport_rect()
		if not viewport_rect.has_point(global_position):
			queue_free()

func _on_body_entered(body):
	# if the ice cube hits the player, hurt them
	if not is_static_wall and body.is_in_group("player"):
		body.take_damage()
		queue_free()
		
	if is_static_wall and body.is_in_group("player"):
		body.take_damage()
		body.bounce_back_from_wall(global_position)

func _on_area_entered(area):
	# if the ice cube is hit by the stick, be hit back
	if area.is_in_group("player_stick"):
		canHurtBoss = true
		velocity = -velocity
	# if the ice cube hits the boss, hurt them
	elif area.is_in_group("boss"):
		if canHurtBoss:
			area.take_damage()
			queue_free()
	# if the ice cube is hit by the puck, break
	elif area.is_in_group("puck"):
		queue_free()

func set_as_static_wall():
	is_static_wall = true
	velocity = Vector2.ZERO
