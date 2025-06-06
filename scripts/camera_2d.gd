extends Camera2D

@export var randomStrength := 30.0
@export var shakeFade := 5.0

var rng = RandomNumberGenerator.new()
var shake_strength := 0.0

func apply_shake():
	shake_strength = randomStrength
	
func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		
		offset = randomOffset()
	
func randomOffset():
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
