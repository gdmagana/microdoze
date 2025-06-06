extends RefCounted
class_name PowerupWeightHelper

# Utility class for weighted powerup selection
# Can be used by any script that wants to do weighted random powerup selection

static func get_weighted_random_powerup_from_config(config: Dictionary) -> PackedScene:
	"""
	Select a random powerup based on weights.
	Config should be a dictionary with powerup scenes as keys and weights as values.
	Example:
	{
		preload("res://scenes/power_ups/SpeedBoostPowerUp.tscn"): 2.0,
		preload("res://scenes/power_ups/FirePucksPowerUp.tscn"): 1.0,
		preload("res://scenes/power_ups/InvincibilityPowerUp.tscn"): 0.5
	}
	"""
	
	if config.is_empty():
		print("WARNING: PowerupWeightHelper received empty config!")
		return null
	
	# Calculate total weight
	var total_weight = 0.0
	for powerup_scene in config:
		var weight = config[powerup_scene]
		if weight > 0:
			total_weight += weight
	
	if total_weight <= 0:
		print("WARNING: All powerup weights are 0 or negative!")
		return null
	
	# Generate random number between 0 and total_weight
	var random_value = randf() * total_weight
	
	# Find which powerup this random value corresponds to
	var current_weight = 0.0
	for powerup_scene in config:
		var weight = config[powerup_scene]
		if weight > 0:
			current_weight += weight
			if random_value <= current_weight:
				return powerup_scene
	
	# Fallback (shouldn't happen with proper weights)
	print("WARNING: PowerupWeightHelper selection failed, using first powerup")
	var first_key = config.keys()[0]
	return first_key

static func get_weighted_random_powerup_from_arrays(powerup_scenes: Array, weights: Array) -> PackedScene:
	"""
	Select a random powerup based on parallel arrays of scenes and weights.
	Both arrays must be the same size.
	"""
	
	if powerup_scenes.size() != weights.size():
		print("ERROR: PowerupWeightHelper - scenes and weights arrays must be same size!")
		return null
	
	if powerup_scenes.is_empty():
		print("WARNING: PowerupWeightHelper received empty arrays!")
		return null
	
	# Calculate total weight
	var total_weight = 0.0
	for weight in weights:
		if weight > 0:
			total_weight += weight
	
	if total_weight <= 0:
		print("WARNING: All powerup weights are 0 or negative!")
		return null
	
	# Generate random number between 0 and total_weight
	var random_value = randf() * total_weight
	
	# Find which powerup this random value corresponds to
	var current_weight = 0.0
	for i in range(powerup_scenes.size()):
		var weight = weights[i]
		if weight > 0:
			current_weight += weight
			if random_value <= current_weight:
				return powerup_scenes[i]
	
	# Fallback (shouldn't happen with proper weights)
	print("WARNING: PowerupWeightHelper selection failed, using first powerup")
	return powerup_scenes[0]

static func calculate_powerup_probabilities(weights: Array) -> Array:
	"""
	Calculate the actual percentage probabilities from weights.
	Returns an array of percentages (0.0 to 1.0) corresponding to each weight.
	"""
	
	var total_weight = 0.0
	for weight in weights:
		if weight > 0:
			total_weight += weight
	
	if total_weight <= 0:
		return []
	
	var probabilities = []
	for weight in weights:
		if weight > 0:
			probabilities.append(weight / total_weight)
		else:
			probabilities.append(0.0)
	
	return probabilities
