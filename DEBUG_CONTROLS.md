# Debug Controls Guide

## Narrative Intro Skip

For faster testing and debugging, you can skip the long narrative intro sequence.

### Setup Instructions

1. **Add DebugSettings to AutoLoad:**
   - Go to **Project > Project Settings**
   - Click on the **AutoLoad** tab
   - In the **Path** field, browse to `scripts/debug_settings.gd`
   - Set **Name** to `DebugSettings`
   - Click **Add**

### Usage Options

#### Option 1: Set Skip Before Starting
1. Open `scripts/debug_settings.gd`
2. Change `@export var skip_narrative_intro := false` to `@export var skip_narrative_intro := true`
3. Run the game - clicking "Start" will skip directly to the boss fight

#### Option 2: Toggle During Gameplay
- **F10**: Jump directly to game from anywhere (emergency debug)

#### Option 3: In Inspector (After AutoLoad Setup)
1. In the Godot editor, go to **Project > Project Settings > AutoLoad**
2. Find **DebugSettings** in the list
3. Check the **Skip Narrative Intro** box in the inspector
4. Run the game

### Debug Output

When debug settings are active, you'll see console messages like:
```
DEBUG: Debug settings loaded
  Skip narrative intro: true
  Powerup debug UI: true
  Debug logs: true
```

### Quick Testing Workflow

1. **First time setup**: Add DebugSettings to AutoLoad
2. **For development**: Set `skip_narrative_intro := true` in the script
3. **Emergency**: Press F10 to jump to game from any scene

### Other Debug Features

- **Powerup Debug UI**: Shows active powerups with timers (already enabled)
- **Debug Logs**: Extensive logging for powerup system debugging
- **F10 Key**: Universal "jump to game" shortcut

### Reverting for Release

Before releasing the game:
1. Set `skip_narrative_intro := false`
2. Remove DebugSettings from AutoLoad (or keep it with skip disabled)
3. Remove F10 input handling if desired 