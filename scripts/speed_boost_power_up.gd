extends BasePowerUp
class_name HealthPowerUp

@export var health_amount: int = 1

func _ready():
	super._ready()
	powerup_type = "health"
	print("DEBUG: HealthPowerUp ready!")

# Virtual method to be overridden by specific powerups
func activate_effect():
	print("DEBUG: HealthPowerUp activate_effect called!")
	if PowerUpManager and PowerUpManager.player:
		var player = PowerUpManager.player
		if player.has_method("add_health"):
			player.add_health(health_amount)
			print("DEBUG: Player healed by ", health_amount)
