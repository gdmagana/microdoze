extends BasePowerUp
class_name InvincibilityPowerUp

@export var invincibility_duration: float = 5.0

func _ready():
	super._ready()
	powerup_type = "invincibility"

func activate_effect():
	# Access the PowerUpManager singleton to activate invincibility
	if PowerUpManager:
		PowerUpManager.activate_invincibility(invincibility_duration)
