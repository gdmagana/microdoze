extends BasePowerUp
class_name FirePucksPowerUp

@export var fire_duration: float = 3.0

func _ready():
	super._ready()
	powerup_type = "fire_pucks"

func activate_effect():	
	# Access the PowerUpManager singleton to activate fire pucks
	if PowerUpManager:
		PowerUpManager.activate_fire_pucks(fire_duration)
