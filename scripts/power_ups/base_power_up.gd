extends Area2D
class_name BasePowerUp

@export var powerup_type: String = "base"
@export var fall_speed: float = 100.0
@export var collection_sound: AudioStream

# Virtual method to be overridden by specific powerups
func activate_effect():
	print("DEBUG: Base powerup activated - override this method!")

func _ready():
	add_to_group("powerups")
	# Set up collision layers - need to detect player's hitbox which is on layer 4
	set_collision_layer(8) # Powerup layer
	set_collision_mask(4) # Player hitbox layer
	
	# Connect collision detection for both body and area
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	

func _process(delta):
	# Make powerup fall slowly
	position.y += fall_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect_powerup()

func _on_area_entered(area):
	# Handle Area2D collisions (like player's hitbox)
	if area.get_parent().is_in_group("player"):
		collect_powerup()

func collect_powerup():
	# Play collection sound if available
	if collection_sound:
		# Create a temporary audio player to play the sound
		var audio_player = AudioStreamPlayer2D.new()
		get_parent().add_child(audio_player)
		audio_player.stream = collection_sound
		audio_player.play()
		# Remove the audio player after sound finishes
		audio_player.finished.connect(audio_player.queue_free)
	
	# Activate the powerup effect
	activate_effect()
	
	# Visual feedback - quick scale animation before disappearing
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.1)
	tween.tween_callback(queue_free)

func _on_visible_on_screen_notifier_2d_screen_exited():
	# Remove powerup if it falls off screen
	queue_free()
