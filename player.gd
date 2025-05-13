extends CharacterBody2D

# Player Movement
@export var acceleration := 800.0
@export var friction := 600.0
@export var max_speed := 500.0
var dx := 0.0

# Stick
var last_direction := 1  # 1 = right, -1 = left
var stick_push_timer := 0.0
var stick_push_duration := 0.15  # seconds
var is_stick_pushing := false

func _physics_process(delta):
	var input_direction := 0
	if Input.is_action_pressed("ui_left"):
		input_direction -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction += 1

	if input_direction != 0:
		last_direction = sign(input_direction)
		dx += input_direction * acceleration * delta
	else:
		# Apply friction to gradually stop
		if abs(dx) < friction * delta:
			dx = 0
		else:
			dx -= sign(dx) * friction * delta

	# Clamp max speed
	dx = clamp(dx, -max_speed, max_speed)

	# Update position manually
	position.x += dx * delta

	# keep the player on screen
	var screen_width = get_viewport_rect().size.x
	position.x = clamp(position.x, 0, screen_width)
	
	# Stick logic
	if Input.is_action_just_pressed("ui_accept") and not is_stick_pushing:
		is_stick_pushing = true
		stick_push_timer = stick_push_duration
	if is_stick_pushing:
		stick_push_timer -= delta
		if stick_push_timer < 0:
			is_stick_pushing = false
			
	var stick_offset := Vector2(50,0) * last_direction
	if is_stick_pushing:
		stick_offset += Vector2(0, -25)
	
	$Stick.position = stick_offset
	
	move_and_slide()



func _on_area_entered(area):
	if area.is_in_group("pucks"):
		print("Hit!")
