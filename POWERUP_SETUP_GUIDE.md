# Powerup System Setup Guide

## Overview
This modular powerup system allows you to easily add temporary effects to your game. The system consists of:

1. **PowerUpManager** - Singleton that manages all powerup effects
2. **BasePowerUp** - Base class for all powerup types  
3. **Specific PowerUps** - SpeedBoost, UnlimitedPucks, FirePucks, and Invincibility
4. **Ice Cube Integration** - Ice cubes can now drop powerups when broken
5. **Visual Preview** - Ice cubes show what powerup they contain with a small pulsing icon
6. **Weighted Probability System** - Control the rarity of each powerup with customizable weights

## Setup Instructions

### 1. Register PowerUpManager as AutoLoad

You MUST add PowerUpManager as an AutoLoad singleton:

1. Go to **Project > Project Settings**
2. Click on the **AutoLoad** tab
3. In the **Path** field, browse to `scripts/power_up_manager.gd`
4. Set **Name** to `PowerUpManager`
5. Click **Add**

This makes PowerUpManager globally accessible throughout your game.

### 2. Available PowerUps

#### Speed Boost PowerUp (Cyan/Blue colored)
- **Effect**: Increases player movement speed by 2x
- **Duration**: 5 seconds (configurable)
- **Scene**: `scenes/SpeedBoostPowerUp.tscn`
- **Visual**: Small cyan puck icon inside ice cubes
- **Default Weight**: 1.0

#### Unlimited Pucks PowerUp (Yellow colored)  
- **Effect**: Allows unlimited puck shooting (ignores max_active_pucks limit)
- **Duration**: 3 seconds (configurable)
- **Scene**: `scenes/UnlimitedPucksPowerUp.tscn`
- **Visual**: Small yellow puck icon inside ice cubes
- **Default Weight**: 1.0

#### Fire Pucks PowerUp (Orange colored)
- **Effect**: Next 3 pucks deal double damage and have fire visual effect
- **Count**: 3 pucks (configurable)  
- **Scene**: `scenes/FirePucksPowerUp.tscn`
- **Visual**: Small orange puck icon inside ice cubes
- **Default Weight**: 1.0

#### Invincibility PowerUp (White colored)
- **Effect**: Player cannot take damage or be frozen for 5 seconds, with rainbow visual effect
- **Duration**: 5 seconds (configurable)
- **Scene**: `scenes/InvincibilityPowerUp.tscn`
- **Visual**: Small white puck icon inside ice cubes + player rainbow effect when active
- **Default Weight**: 0.5 (half as likely since it's very powerful)

### 3. Weighted Probability System

**New Feature**: Control how often each powerup appears using weight ratios!

#### How It Works:
- Each powerup has a **weight** value (higher = more likely to appear)
- Weights are **ratios**, not percentages
- Setting a powerup weight to 0 **disables** it completely

#### Example Weight Scenarios:

**Equal Chances (Default):**
- Speed Boost: 1.0
- Unlimited Pucks: 1.0  
- Fire Pucks: 1.0
- Invincibility: 1.0
- **Result**: Each powerup has 25% chance

**Speed Boost Favored:**
- Speed Boost: 3.0
- Unlimited Pucks: 1.0
- Fire Pucks: 1.0  
- Invincibility: 1.0
- **Result**: Speed Boost 50%, others 16.7% each

**Rare Invincibility:**
- Speed Boost: 2.0
- Unlimited Pucks: 2.0
- Fire Pucks: 2.0
- Invincibility: 1.0
- **Result**: Invincibility 14.3%, others 28.6% each

**No Fire Pucks:**
- Speed Boost: 1.0
- Unlimited Pucks: 1.0
- Fire Pucks: 0.0 (disabled)
- Invincibility: 1.0
- **Result**: Fire pucks never appear, others 33.3% each

#### Configuring Weights:

1. **In Boss Script** (affects ice wall powerups):
   - Select the boss in your scene
   - In Inspector, find **Powerups > Powerup Probabilities**
   - Adjust the weight values:
	 - `Speed Boost Weight`
	 - `Unlimited Pucks Weight`
	 - `Fire Pucks Weight`
	 - `Invincibility Weight`

2. **For Custom Scripts** (using PowerupWeightHelper):
```gdscript
# Method 1: Using arrays
var powerup_scenes = [speed_scene, fire_scene, invincibility_scene]
var weights = [2.0, 1.0, 0.5]  # Speed 2x likely, invincibility half as likely
var selected_powerup = PowerupWeightHelper.get_weighted_random_powerup_from_arrays(powerup_scenes, weights)

# Method 2: Using dictionary
var powerup_config = {
	preload("res://scenes/SpeedBoostPowerUp.tscn"): 3.0,
	preload("res://scenes/FirePucksPowerUp.tscn"): 1.0,
	preload("res://scenes/InvincibilityPowerUp.tscn"): 0.5
}
var selected_powerup = PowerupWeightHelper.get_weighted_random_powerup_from_config(powerup_config)
```

### 4. Visual Powerup Previews

Ice cubes now show what powerup they contain!

- **Small Icon**: A miniature version of the powerup appears above the ice cube
- **Color Coded**: The icon uses the same color as the actual powerup
- **Pulsing Effect**: The icon gently pulses to make it more noticeable
- **Strategic Gameplay**: Players can now choose which ice cubes to prioritize based on the powerup they want

### 5. Adding Powerups to Ice Cubes

#### Option A: In the Godot Editor
1. Select an ice cube in your scene
2. In the Inspector, find the **IceCube** script properties
3. Set **Powerup Scene** to one of the powerup scenes (e.g., `SpeedBoostPowerUp.tscn`)
4. Set **Powerup Drop Chance** (0.0 = never, 1.0 = always, 0.3 = 30% chance)
5. **The powerup icon will automatically appear above the ice cube!**

#### Option B: Programmatically  
```gdscript
# Example: Make an ice cube drop a speed boost with 50% chance
var ice_cube = ice_cube_scene.instantiate()
var speed_powerup_scene = preload("res://scenes/SpeedBoostPowerUp.tscn")
ice_cube.set_powerup(speed_powerup_scene, 0.5)
# The powerup preview will automatically show when added to scene
```

### 6. Creating Custom PowerUps

To create a new powerup:

1. **Create the Script** (extend BasePowerUp):
```gdscript
extends BasePowerUp
class_name YourCustomPowerUp

@export var custom_duration: float = 10.0

func _ready():
	super._ready()
	powerup_type = "your_custom_type"

func activate_effect():
	# Add your custom effect here
	print("Custom powerup activated!")
	# You can access PowerUpManager for complex effects
	if PowerUpManager:
		# Add custom logic to PowerUpManager if needed
		pass
```

2. **Create the Scene**:
- Inherit from `BasePowerUp.tscn`
- Assign your custom script
- Change the sprite color/texture for visual distinction
- **The preview will automatically use your custom sprite and color!**

3. **Add to Boss Weights** (optional):
- Add your new powerup to the boss's `_load_powerup_scenes()` function
- Add a corresponding weight export variable

### 7. Boss Integration Example

The boss now uses weighted selection automatically! You can adjust weights in the Inspector.

For custom powerup drops:
```gdscript
# Custom weighted powerup drop
var powerup_config = {
	preload("res://scenes/SpeedBoostPowerUp.tscn"): 2.0,
	preload("res://scenes/YourCustomPowerUp.tscn"): 1.0
}
var selected_powerup = PowerupWeightHelper.get_weighted_random_powerup_from_config(powerup_config)
if selected_powerup:
	ice_cube.set_powerup(selected_powerup, 1.0)
```

## Testing the System

1. Set up PowerUpManager as AutoLoad (step 1 above)
2. Adjust powerup weights in the boss Inspector
3. Run the game and fight the boss
4. **Look for ice cubes with small colored icons above them** - these contain powerups!
5. Break those special ice cubes to get the powerups
6. Notice the frequency of different powerups matches your weight settings
7. Collect the falling powerup to activate the effect

## Weight Balancing Tips

- **Common powerups**: 1.0-2.0 weight
- **Rare powerups**: 0.3-0.8 weight  
- **Super rare powerups**: 0.1-0.3 weight
- **Disabled powerups**: 0.0 weight
- **Overpowered powerups**: Lower weights (like Invincibility at 0.5)

The system is fully modular with rich visual feedback and precise control over powerup rarity! 
