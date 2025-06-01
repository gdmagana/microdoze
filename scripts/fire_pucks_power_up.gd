extends BasePowerUp
class_name FirePucksPowerUp

@export var fire_duration: float = 3.0

func _ready():
	super._ready()
	powerup_type = "fire_pucks"
	print("DEBUG: FirePucksPowerUp ready!")

func activate_effect():
	print("DEBUG: FirePucksPowerUp activate_effect called!")
	print("DEBUG: PowerUpManager exists: ", PowerUpManager != null)
	
	# Access the PowerUpManager singleton to activate fire pucks
	if PowerUpManager:
		print("DEBUG: Calling PowerUpManager.activate_fire_pucks(", fire_duration, ")")
		PowerUpManager.activate_fire_pucks(fire_duration)
		print("DEBUG: Fire pucks activated! 2x speed for ", fire_duration, " seconds!")
	else:
		print("ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!")