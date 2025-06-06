extends Sprite2D

var damage_flash_duration := 0.3

func take_damage():
	modulate = Color(1, 0, 0)
	
	# Create a tween to fade back to normal
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), damage_flash_duration)

func run_away():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 600, 1.5)
	tween.tween_callback(Callable(self, "queue_free"))
