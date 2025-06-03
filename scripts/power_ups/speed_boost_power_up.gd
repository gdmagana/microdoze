extends BasePowerUp
class_name SpeedBoostPowerUp

@export var speed_duration: float = 5.0

func _ready():
	super._ready()
	powerup_type = "speed_boost"
	print("DEBUG: SpeedBoostPowerUp ready!")

func activate_effect():
	print("DEBUG: SpeedBoostPowerUp activate_effect called!")
	print("DEBUG: PowerUpManager exists: ", PowerUpManager != null)
	
	# Access the PowerUpManager singleton to activate speed boost
	if PowerUpManager:
		print("DEBUG: Calling PowerUpManager.activate_speed_boost(", speed_duration, ")")
		PowerUpManager.activate_speed_boost(speed_duration)
		print("DEBUG: Speed boost activated for ", speed_duration, " seconds!")
	else:
		print("ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!")