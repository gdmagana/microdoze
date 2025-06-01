extends BasePowerUp
class_name InvincibilityPowerUp

@export var invincibility_duration: float = 5.0

func _ready():
	super._ready()
	powerup_type = "invincibility"
	print("DEBUG: InvincibilityPowerUp ready!")

func activate_effect():
	print("DEBUG: InvincibilityPowerUp activate_effect called!")
	print("DEBUG: PowerUpManager exists: ", PowerUpManager != null)
	
	# Access the PowerUpManager singleton to activate invincibility
	if PowerUpManager:
		print("DEBUG: Calling PowerUpManager.activate_invincibility(", invincibility_duration, ")")
		PowerUpManager.activate_invincibility(invincibility_duration)
		print("DEBUG: Invincibility activated for ", invincibility_duration, " seconds!")
	else:
		print("ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!")