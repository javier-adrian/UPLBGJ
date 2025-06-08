extends Control

# Example usage of the CircularQTE system
# This script demonstrates how to integrate and customize the circular QTE

@onready var circular_qte = $CircularQTE  # Assumes CircularQTE node is a child

var current_difficulty_level: int = 1
var qte_count: int = 0

func _ready():
	# Connect to QTE results and combo signals
	if circular_qte:
		circular_qte.qte_result.connect(_on_qte_completed)
		circular_qte.combo_completed.connect(_on_combo_completed)
		circular_qte.combo_broken.connect(_on_combo_broken)

	# Set initial difficulty
	set_difficulty_level(current_difficulty_level)

func _input(event):
	# Example: Change difficulty with number keys
	if event.is_action_pressed("ui_accept"):  # Enter key
		start_continuous_qte()
	elif Input.is_action_just_pressed("ui_up"):
		increase_difficulty()
	elif Input.is_action_just_pressed("ui_down"):
		decrease_difficulty()
	elif event.is_action_pressed("ui_cancel"):  # Escape key
		reset_counters()
	elif Input.is_action_just_pressed("ui_left"):  # Left arrow - enable combo mode
		enable_combo_mode()
	elif Input.is_action_just_pressed("ui_right"):  # Right arrow - disable combo mode
		disable_combo_mode()

func start_continuous_qte():
	"""Start the continuous QTE system"""
	if circular_qte:
		print("Starting continuous QTE system")
		circular_qte.start_qte()

func reset_counters():
	"""Reset all QTE counters"""
	if circular_qte:
		circular_qte.reset_counters()
		print("Counters reset")

func enable_combo_mode():
	"""Enable combo mode with 5 hit target"""
	if circular_qte:
		circular_qte.enable_combo_mode(5, false)  # 5 hits, perfect not required

func disable_combo_mode():
	"""Disable combo mode"""
	if circular_qte:
		circular_qte.disable_combo_mode()

func _on_qte_completed(result, accuracy: float):
	"""Handle QTE completion"""
	var result_text = ""
	match result:
		circular_qte.TimingResult.PERFECT:
			result_text = "PERFECT"
		circular_qte.TimingResult.GOOD:
			result_text = "GOOD"
		circular_qte.TimingResult.MISS:
			result_text = "MISS"

	print("QTE Result: %s (%.1f%% accuracy) - Total attempts: %d" % [result_text, accuracy, circular_qte.total_attempts])

	# Example: Increase difficulty after successful streaks
	if result != circular_qte.TimingResult.MISS:
		if circular_qte.total_attempts % 10 == 0:  # Every 10 attempts
			increase_difficulty()

func _on_combo_completed(combo_count: int, perfect_hits: int, good_hits: int):
	"""Handle combo completion"""
	print("🎉 COMBO COMPLETED! %d hits in a row (%d perfect, %d good)" % [combo_count, perfect_hits, good_hits])
	print("QTE has ended due to combo completion!")

	# Example: Could trigger special effects, rewards, etc.
	# award_bonus_points(combo_count * 100)
	# play_success_animation()

func _on_combo_broken(combo_count: int):
	"""Handle combo being broken"""
	if combo_count > 0:
		print("💥 Combo broken at %d hits!" % combo_count)
	# Example: Could trigger failure effects
	# play_failure_sound()

func set_difficulty_level(level: int):
	"""Set difficulty level (1-4)"""
	current_difficulty_level = clamp(level, 1, 4)
	
	if not circular_qte:
		return
	
	match current_difficulty_level:
		1:
			circular_qte.set_easy_difficulty()
			print("Difficulty: EASY")
		2:
			circular_qte.set_normal_difficulty()
			print("Difficulty: NORMAL")
		3:
			circular_qte.set_hard_difficulty()
			print("Difficulty: HARD")
		4:
			circular_qte.set_expert_difficulty()
			print("Difficulty: EXPERT")

func increase_difficulty():
	"""Increase difficulty level"""
	if current_difficulty_level < 4:
		set_difficulty_level(current_difficulty_level + 1)

func decrease_difficulty():
	"""Decrease difficulty level"""
	if current_difficulty_level > 1:
		set_difficulty_level(current_difficulty_level - 1)

# Example: Custom QTE configurations
func setup_boss_qte():
	"""Example: Setup for a boss battle QTE"""
	if circular_qte:
		circular_qte.set_difficulty(2.5)  # Very fast
		circular_qte.set_timing_zones(5.0, 12.0)  # Very precise timing
		circular_qte.set_target_position(0.0)  # Target at top

func setup_rhythm_qte():
	"""Example: Setup for rhythm game integration"""
	if circular_qte:
		circular_qte.set_difficulty(1.2)  # Slightly faster than normal
		circular_qte.set_timing_zones(12.0, 25.0)  # Moderate timing
		circular_qte.set_target_position(90.0)  # Target at right side
