extends BasePowerUp
class_name FirePucksPowerUp

@export var fire_puck_count: int = 3

func _ready():
	super._ready()
	powerup_type = "fire_pucks"
	print("DEBUG: FirePucksPowerUp ready!")

func activate_effect():
	print("DEBUG: FirePucksPowerUp activate_effect called!")
	print("DEBUG: PowerUpManager exists: ", PowerUpManager != null)
	
	# Access the PowerUpManager singleton to activate fire pucks
	if PowerUpManager:
		print("DEBUG: Calling PowerUpManager.activate_fire_pucks(", fire_puck_count, ")")
		PowerUpManager.activate_fire_pucks(fire_puck_count)
		print("DEBUG: Fire pucks activated! ", fire_puck_count, " fire pucks available!")
	else:
		print("ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!")