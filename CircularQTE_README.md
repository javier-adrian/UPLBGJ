# Circular QTE System

A customizable circular Quick Time Event (QTE) system for Godot 4, featuring perfect/good/miss timing zones, visual feedback, and difficulty adjustment.

## Features

- **Continuous spinning indicator** that never stops rotating
- **Three timing zones**: Perfect (red), Good (orange), Miss (everything else)
- **Real-time counter display** showing Perfect/Good/Miss counts and accuracy
- **Combo/Streak system** with adjustable targets that ends QTE on completion
- **Visual feedback** with color changes and result text
- **Difficulty adjustment** through rotation speed and timing zone sizes
- **Integration** with existing Manager scoring system
- **Customizable appearance** and behavior

## Setup

1. Add the `CircularQTE.gd` script to your scene
2. The script extends `Control`, so attach it to a Control node
3. The QTE will automatically start when the node is ready

## Basic Usage

```gdscript
# Get reference to the CircularQTE node
@onready var qte = $CircularQTE

# Connect to results
qte.qte_result.connect(_on_qte_result)

# Start the continuous QTE system
qte.start_qte()

func _on_qte_result(result, accuracy):
    match result:
        qte.TimingResult.PERFECT:
            print("Perfect hit! Total: %d" % qte.perfect_count)
        qte.TimingResult.GOOD:
            print("Good hit! Total: %d" % qte.good_count)
        qte.TimingResult.MISS:
            print("Missed! Total: %d" % qte.miss_count)

    print("Overall accuracy: %.1f%%" % (float(qte.perfect_count + qte.good_count) / qte.total_attempts * 100))
```

## Counter System

The QTE automatically tracks and displays:

- **Total attempts**: Number of times spacebar was pressed
- **Perfect count**: Number of perfect hits
- **Good count**: Number of good hits
- **Miss count**: Number of missed hits
- **Accuracy percentage**: (Perfect + Good) / Total \* 100

```gdscript
# Reset all counters
qte.reset_counters()

# Access counter values
print("Perfect: %d, Good: %d, Miss: %d" % [qte.perfect_count, qte.good_count, qte.miss_count])
```

## Combo/Streak System

The QTE can be configured to end automatically when a certain number of consecutive hits are achieved:

```gdscript
# Enable combo mode - QTE ends after 5 consecutive successful hits
qte.enable_combo_mode(5, false)  # 5 hits, perfect not required

# Enable strict combo mode - only perfect hits count
qte.enable_combo_mode(3, true)   # 3 perfect hits required

# Connect to combo signals
qte.combo_completed.connect(_on_combo_completed)
qte.combo_broken.connect(_on_combo_broken)

func _on_combo_completed(combo_count, perfect_hits, good_hits):
    print("Combo completed! %d hits achieved" % combo_count)
    # QTE automatically ends here

func _on_combo_broken(combo_count):
    print("Combo broken at %d hits" % combo_count)
    # Combo resets to 0, QTE continues

# Disable combo mode to return to continuous spinning
qte.disable_combo_mode()
```

### Combo Display

When combo mode is enabled, the counter shows:

- **Combo progress**: "Combo: 3/5"
- **Progress bar**: Visual indicator of combo progress
- **Color coding**: Yellow when active, gray when at 0

## Configuration

### Difficulty Presets

```gdscript
qte.set_easy_difficulty()    # Slow speed, large timing zones
qte.set_normal_difficulty()  # Default settings
qte.set_hard_difficulty()    # Fast speed, small timing zones
qte.set_expert_difficulty()  # Very fast, very small zones
```

### Custom Configuration

```gdscript
# Set rotation speed (degrees per second)
qte.set_difficulty(1.5)  # 1.5x normal speed

# Set timing zone sizes (in degrees)
qte.set_timing_zones(10.0, 25.0)  # Perfect: ±10°, Good: ±25°

# Set target position (0° = top, 90° = right, etc.)
qte.set_target_position(45.0)  # Target at top-right
```

### Visual Customization

```gdscript
# Modify these properties in the script or via export variables
qte.circle_radius = 120.0
qte.perfect_zone_color = Color.BLUE
qte.good_zone_color = Color.GREEN
qte.rotation_speed = 240.0
```

## Controls

- **Spacebar** (or "playing" action): Trigger the QTE timing check

## Integration with Existing Systems

The CircularQTE automatically integrates with your existing Manager system:

- **Perfect hits**: +250 points, increment combo
- **Good hits**: +100 points, increment combo
- **Misses**: Reset combo

## Advanced Usage

### Pausing and Resuming

```gdscript
qte.pause_qte()   # Pause rotation
qte.resume_qte()  # Resume rotation
qte.stop_qte()    # Stop completely
```

### Real-time Monitoring

```gdscript
# Check current timing zone
var current_zone = qte.get_current_timing_zone()

# Get current accuracy percentage
var accuracy = qte.calculate_accuracy()
```

### Custom Scenarios

```gdscript
# Boss battle QTE - very precise
qte.set_difficulty(3.0)
qte.set_timing_zones(5.0, 10.0)

# Casual mini-game - forgiving
qte.set_difficulty(0.7)
qte.set_timing_zones(25.0, 45.0)
```

## Scene Structure

Your scene should look like this:

```
CircQte (Control) - with CircularQTE.gd script
```

The script handles all drawing and logic internally using Godot's `_draw()` function.

## Timing Zones

- **Perfect Zone**: Red bar area (default ±15°)
- **Good Zone**: Orange area extending beyond perfect (default ±30°)
- **Miss Zone**: Everything else

## Tips

1. **Difficulty Progression**: Start easy and gradually increase speed/precision
2. **Visual Clarity**: Ensure good contrast between zones and background
3. **Audio Feedback**: Consider adding sound effects for different results
4. **Accessibility**: Provide visual indicators for timing zones
5. **Testing**: Use the example script to test different configurations

## Troubleshooting

- **QTE not visible**: Ensure the Control node has sufficient size
- **Input not working**: Check that "playing" action is mapped to spacebar
- **No scoring**: Verify Manager autoload is properly configured
- **Performance issues**: Reduce circle resolution in draw_arc calls
