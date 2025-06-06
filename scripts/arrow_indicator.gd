extends Sprite2D

var flashing := false

func start_flashing():
	flashing = true
	_flash()
	
func stop_flashing():
	flashing = false
	modulate = Color(1, 1, 1, 1) # Reset to fully visible
	
func _flash():
	if not flashing:
		return
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.2, 0.6) # Fade out
	tween.tween_property(self, "modulate:a", 1.0, 0.6) # Fade in 
	tween.tween_callback(Callable(self, "_flash"))
