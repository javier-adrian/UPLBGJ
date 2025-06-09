extends Node2D

# Track end screen state globally
var end_screen_showing: bool = false
# Track if we're returning to main menu from game
var returning_from_game: bool = false

# Global hit counters
var perfect_count: int = 0
var great_count: int = 0
var good_count: int = 0
var uninstall_count: int = 0
var miss_count: int = 0
var total_attempts: int = 0

signal increment_score(n: int)

signal increment_combo(n: int)
signal reset_combo()

signal spawn_note(key: String)

signal listener_press(key: String, index: int)

signal decrement_spirit(value: float)
signal increment_spirit(value: float)

# New signals for game success/failure
signal game_success()
signal game_failure()

# Signal for returning to main menu
signal returning_to_main_menu()

# New signals for hit tracking
signal hit_perfect()
signal hit_great()
signal hit_good()
signal hit_uninstall()
signal hit_miss()

# Functions to manage hit counters
func reset_hit_counters():
	print("Resetting hit counters")
	perfect_count = 0
	great_count = 0
	good_count = 0
	uninstall_count = 0
	miss_count = 0
	total_attempts = 0

func record_hit_perfect():
	perfect_count += 1
	total_attempts += 1
	print("✅ PERFECT hit recorded! Perfect: ", perfect_count, " | Total: ", total_attempts)

func record_hit_great():
	great_count += 1
	total_attempts += 1
	print("✅ GREAT hit recorded! Great: ", great_count, " | Total: ", total_attempts)

func record_hit_good():
	good_count += 1
	total_attempts += 1
	print("✅ GOOD hit recorded! Good: ", good_count, " | Total: ", total_attempts)

func record_hit_uninstall():
	uninstall_count += 1
	total_attempts += 1
	print("✅ UNINSTALL hit recorded! Uninstall: ", uninstall_count, " | Total: ", total_attempts)

func record_hit_miss():
	miss_count += 1
	total_attempts += 1
	print("❌ MISS recorded! Miss: ", miss_count, " | Total: ", total_attempts)

func get_accuracy_percentage() -> float:
	if total_attempts == 0:
		return 0.0
	return float(perfect_count + great_count + good_count) / float(total_attempts) * 100.0

func print_hit_stats():
	print("=== HIT STATISTICS ===")
	print("Perfect: ", perfect_count)
	print("Great: ", great_count)
	print("Good: ", good_count)
	print("Uninstall: ", uninstall_count)
	print("Miss: ", miss_count)
	print("Total: ", total_attempts)
	print("Accuracy: ", "%.1f%%" % get_accuracy_percentage())
	print("======================")

# Function to print current stats during gameplay
func print_current_stats():
	print("📊 Current Stats - P:", perfect_count, " G:", great_count, " Good:", good_count, " U:", uninstall_count, " M:", miss_count, " Total:", total_attempts)
