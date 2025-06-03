extends BasePowerUp
class_name UnlimitedPucksPowerUp

@export var unlimited_duration: float = 3.0

func _ready():
	super._ready()
	powerup_type = "unlimited_pucks"

func activate_effect():
	# Access the PowerUpManager singleton to activate unlimited pucks
	if PowerUpManager:
		PowerUpManager.activate_unlimited_pucks(unlimited_duration)
