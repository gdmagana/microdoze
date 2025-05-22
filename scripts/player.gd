extends CharacterBody2D

@onready var health_ui = get_tree().get_current_scene().get_node("HUD/HealthUI")

# -- Player Health --
@export var health := 3

# -- Player Movement --
@export var acceleration := 800.0
@export var friction := 600.0
@export var max_speed := 500.0

var is_frozen := false
var frozen_timer := 0.0
var can_move_up := false

# -- Stick --
var last_direction := 1  # 1 = right, -1 = left
var stick_push_timer := 0.0
var stick_push_duration := 0.15  # seconds
var is_stick_pushing := false
var stick_base_offset := Vector2(50, 0)
var stick_extended_offset := Vector2(50, -25)
var stick_rotation_max := -0.5  # Maximum rotation in radians

# -- Puck --
@export var puck_scene: PackedScene
@export var puck_speed := 700.0
var can_shoot_puck = false

# -- Stage Bounds --
var stage_width
var stage_height

func _ready():
	add_to_group("player")
	$Stick.add_to_group("player_stick")
	
	stage_width = get_viewport_rect().size.x
	stage_height = get_viewport_rect().size.y
	
	health_ui.update_health(health)
	$Hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))	

func take_damage(amount := 1):
	health -= amount
	health_ui.update_health(health)
	
func freeze():
	is_frozen = true
	frozen_timer = 2.0  # seconds
	$Sprite2D.modulate = Color(0.5, 0.5, 1.0)  # light blue
	$"../audio/Pain1".play()
	
func bounce_back_from_wall(wall_pos):
	var bounce_dir = (position - wall_pos).normalized()
	velocity = bounce_dir * 400
	
func enable_vertical_movement():
	can_move_up = true
	
func enable_puck_shooting():
	can_shoot_puck = true
	
func shoot_puck():
	var puck = puck_scene.instantiate()
	get_parent().add_child(puck)
	puck.global_position = $Stick.global_position
	puck.velocity = Vector2(0, -puck_speed)

func _physics_process(delta):
	if is_frozen:
		frozen_timer -= delta
		if frozen_timer <= 0:
			is_frozen = false
			$Sprite2D.modulate = Color(1, 1, 1)  # back to normal
		return  # skip movement while frozen
		
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if can_move_up:
		if Input.is_action_pressed("ui_up"):
			input_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			input_direction.y += 1

	# -- Movement Physics --
	# Horizontal
	if input_direction.x != 0:
		last_direction = sign(input_direction.x)
		velocity.x += input_direction.x * acceleration * delta
	else:
		# Apply friction to gradually stop
		if abs(velocity.x) < friction * delta:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * friction * delta
			
	# clamp max horizontal speed
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	
	# Vertical
	if can_move_up:
		if input_direction.y != 0:
			velocity.y += input_direction.y * acceleration * delta
		else:
			if abs(velocity.y) < friction * delta:
				velocity.y = 0
			else:
				velocity.y -= sign(velocity.y) * friction * delta
				
			velocity.y = clamp(velocity.y, -max_speed, max_speed)
	else:
		velocity.y = 0

	move_and_slide()
	
	# clamp player movement to screen bounds
	position.x = clamp(position.x, 0, stage_width)
	position.y = clamp(position.y, 0, stage_height)
	
	# -- Player Hitbox --
	var hitbox = $CollisionShape2D.shape
	var hitbox_radius = hitbox.radius
	
	# -- Stick logic --
	if Input.is_action_just_pressed("ui_accept") and not is_stick_pushing:
		is_stick_pushing = true
		stick_push_timer = stick_push_duration
	if is_stick_pushing:
		stick_push_timer -= delta
		if stick_push_timer < 0:
			is_stick_pushing = false
			
	# Stick position offset and flip with smooth animation
	var progress := 0.0
	if is_stick_pushing:
		# Calculate smooth progress (ease out)
		progress = 1.0 - (stick_push_timer / stick_push_duration)
		progress = ease(progress, 0.5)  # Smooth easing function
	
	# Interpolate between base and extended position
	var stick_offset = stick_base_offset.lerp(stick_extended_offset, progress)
	stick_offset.x *= last_direction
	
	# Apply smooth rotation
	var rotation = stick_rotation_max * progress * last_direction
	
	$Stick.position = stick_offset
	$Stick.rotation = rotation
	$Stick.scale.x = last_direction  # Flip the stick sprite to face correct side
	
	# -- Puck Shooting --
	if can_shoot_puck and Input.is_action_just_pressed("shoot_puck"):
		shoot_puck()

func _on_hitbox_body_entered(body):
	if body.is_in_group("pucks") or body.is_in_group(""):
		take_damage()
