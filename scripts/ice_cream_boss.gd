extends Area2D

@export var projectile_ice_cube_scene: PackedScene
@export var projectile_ice_cream_scoop: PackedScene
@export var projectile_icicle: PackedScene

@export var throw_speed := 400.0
@export var hits_to_ice_wall_rage := 3
@export var damage_flash_duration := 0.3

# randomness used for later
var rng = RandomNumberGenerator.new()

var player: Node2D
var is_raging := false

func _ready():
	add_to_group("boss")
	player = get_tree().get_current_scene().find_child("Player", true, false)
	$Timer.timeout.connect(_on_Timer_timeout)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("puck"):
		# Use call_deferred to avoid changing physics state during physics processing
		call_deferred("take_damage")

	if body.is_in_group("ice_cube"):
		# If an ice cube hits the boss, take damage
		call_deferred("take_damage")
	
func _on_Timer_timeout():
	if player:
		rng.randomize()
		var random_number = rng.randi_range(0, 2)

		var projectile
		var direction

		if random_number < 2:
			# "throw" the icicle projectiles at the player
			if random_number== 0:
				projectile = projectile_ice_cube_scene.instantiate()
			else:
				projectile = projectile_icicle.instantiate()
			direction = (player.global_position - global_position).normalized()
		else:
			# "throw" the ice cream scoop at a random position
			projectile = projectile_ice_cream_scoop.instantiate()
			
			# Pick a random x within screen width, y slightly below screen
			var viewport_size = get_viewport().get_visible_rect().size
			var random_x = rng.randi_range(0, int(viewport_size.x))
			var target_point = Vector2(random_x, viewport_size.y + 100)
			direction = (target_point - global_position).normalized()

		get_parent().add_child(projectile)
		projectile.global_position = global_position
		projectile.velocity = direction * throw_speed

func take_damage(amount := 1):
	hits_to_ice_wall_rage -= amount
	
	# Play damage sound if we can find one
	# if get_node_or_null("../audio/Pain1") != null:
	# 	$"../audio/Pain1".play()
	# elif get_node_or_null("/root/Main/audio/Pain1") != null:
	# 	$"/root/Main/audio/Pain1".play()
	
	# Flash red
	damage_flash()
	
	if not is_raging and hits_to_ice_wall_rage == 0:
		rage()
	else:
		throw_ice_wall(-200)

# Flash the boss red when taking damage
func damage_flash():
	# Set sprite to red
	$Sprite2D.modulate = Color(1, 0, 0)
	
	# Create a tween to fade back to normal
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), damage_flash_duration)

func rage():
	is_raging = true
	run_away()
	if player:
		player.enable_vertical_movement()
		player.enable_puck_shooting()
	call_deferred("throw_ice_wall")
	call_deferred("throw_ice_wall", -100)
	
func throw_ice_wall(y_offset = null):
	var screen_width = get_viewport_rect().size.x
	var ice_cube_width = 100
	var y_pos = null
	if not y_offset:
		y_pos = global_position.y - 100
	else:
		y_pos = global_position.y - y_offset
	for x in range(0, screen_width, ice_cube_width):
		var ice_cube = projectile_ice_cube_scene.instantiate()
		get_parent().add_child(ice_cube)
		ice_cube.global_position = Vector2(x + ice_cube_width/2, y_pos)
		ice_cube.set_as_static_wall()
	
func run_away():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 300, 1.5)
	tween.tween_callback(Callable(self, "queue_free"))
