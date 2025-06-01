extends BasePowerUp
class_name UnlimitedPucksPowerUp

@export var unlimited_duration: float = 3.0

func _ready():
	super._ready()
	powerup_type = "unlimited_pucks"
	print("DEBUG: UnlimitedPucksPowerUp ready!")

func activate_effect():
	print("DEBUG: UnlimitedPucksPowerUp activate_effect called!")
	print("DEBUG: PowerUpManager exists: ", PowerUpManager != null)
	
	# Access the PowerUpManager singleton to activate unlimited pucks
	if PowerUpManager:
		print("DEBUG: Calling PowerUpManager.activate_unlimited_pucks(", unlimited_duration, ")")
		PowerUpManager.activate_unlimited_pucks(unlimited_duration)
		print("DEBUG: Unlimited pucks activated for ", unlimited_duration, " seconds!")
	else:
		print("ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!")