# Powerup Debug Setup

## Quick Setup

1. **Add Debug UI to Main Scene:**
   - Open your `Level1.tscn` scene
   - Right-click and select "Instance Scene"
   - Choose `scenes/PowerupDebugUI.tscn`
   - Position it anywhere in your scene

2. **Check Console Output:**
   - When you run the game, look for debug messages in the console
   - Look for messages like:
     - "DEBUG: Powerup ready: speed_boost"
     - "DEBUG: PowerUpManager exists: true/false"
     - "ERROR: PowerUpManager not found!"

## What to Look For

### If PowerUpManager is NOT set up as AutoLoad:
```
ERROR: PowerUpManager not found! Make sure it's set up as AutoLoad!
```
**Solution:** Go to Project Settings → AutoLoad → Add `scripts/power_up_manager.gd` as `PowerUpManager`

### If PowerUpManager IS working:
```
DEBUG: SpeedBoostPowerUp activate_effect called!
DEBUG: PowerUpManager exists: true
DEBUG: Calling PowerUpManager.activate_speed_boost(5.0)
DEBUG: Speed boost activated for 5.0 seconds!
```

### Debug UI Should Show:
- **Speed Boost: ON (4.5s)** - When speed boost is active
- **Unlimited Pucks: ON (2.1s)** - When unlimited pucks is active  
- **Fire Pucks: ON (3 left)** - When fire pucks is active

## Common Issues

1. **PowerUpManager not found** = AutoLoad not set up
2. **Powerups collect but no effect** = PowerUpManager not receiving the calls
3. **Debug UI shows "PowerUpManager NOT FOUND!"** = Definitely an AutoLoad issue

## Remove Debug After Testing

Once everything works, you can:
- Remove the debug UI from your scene
- Remove debug print statements from the powerup scripts
- Keep the system running normally 