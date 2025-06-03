extends BasePowerUp
class_name HealthPowerUp

@export var health_amount: int = 1

func _ready():
	super._ready()
	powerup_type = "health"

# Virtual method to be overridden by specific powerups
func activate_effect():
	if PowerUpManager and PowerUpManager.player:
		var player = PowerUpManager.player
		if player.has_method("add_health"):
			player.add_health(health_amount)
