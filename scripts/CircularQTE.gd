extends Control

# Circular QTE System
# Features: Perfect/Good/Miss timing zones, visual feedback, difficulty adjustment

# QTE Configuration
@export var rotation_speed: float = 180.0  # degrees per second
@export var perfect_zone_angle: float = 15.0  # degrees for perfect timing
@export var good_zone_angle: float = 30.0  # degrees for good timing (extends beyond perfect)
@export var target_angle: float = 0.0  # where the red bar is positioned (top = 0°)

# Visual Configuration
@export var circle_radius: float = 100.0
@export var circle_thickness: float = 8.0
@export var indicator_length: float = 120.0
@export var indicator_thickness: float = 6.0

# Colors
var circle_color: Color = Color.WHITE
var perfect_zone_color: Color = Color.RED
var good_zone_color: Color = Color.ORANGE
var indicator_color: Color = Color.CYAN
var background_color: Color = Color(0.1, 0.1, 0.1, 0.8)

# State variables
var current_angle: float = 180.0  # start at bottom (opposite of target)
var is_active: bool = false
var qte_completed: bool = false

# Counter variables
var perfect_count: int = 0
var good_count: int = 0
var miss_count: int = 0
var total_attempts: int = 0

# Combo/Streak system variables
@export var combo_target: int = 5  # Number of consecutive hits needed to complete QTE
@export var combo_requires_perfect: bool = false  # If true, only perfect hits count for combo
var current_combo: int = 0
var combo_enabled: bool = false

# Timing result enum
enum TimingResult {
	MISS,
	GOOD,
	PERFECT
}

# Signals
signal qte_result(result: TimingResult, accuracy: float)
signal combo_completed(combo_count: int, perfect_hits: int, good_hits: int)
signal combo_broken(combo_count: int)

func _ready():
	# Connect to existing manager signals if available
	if Manager:
		qte_result.connect(_on_qte_result)
	
	# Set up the control
	custom_minimum_size = Vector2(250, 250)
	
	# Start the QTE
	start_qte()

func _draw():
	var center = size / 2

	# Draw background circle
	draw_circle(center, circle_radius + 20, background_color)

	# Draw main circle outline
	draw_arc(center, circle_radius, 0, TAU, 64, circle_color, circle_thickness)

	# Draw timing zones
	draw_timing_zones(center)

	# Draw rotating indicator
	draw_indicator(center)

	# Draw instruction text or feedback
	var font = ThemeDB.fallback_font
	if showing_feedback:
		# Show result feedback
		var result_text = ""
		var result_color = Color.WHITE
		match last_result:
			TimingResult.PERFECT:
				result_text = "PERFECT!"
				result_color = Color.GREEN
			TimingResult.GOOD:
				result_text = "GOOD!"
				result_color = Color.YELLOW
			TimingResult.MISS:
				result_text = "MISS!"
				result_color = Color.RED

		var text_size = font.get_string_size(result_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
		draw_string(font, center - text_size/2 + Vector2(0, 40), result_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, result_color)
	elif is_active:
		# Show instruction
		var text = "Press SPACE!"
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		draw_string(font, center - text_size/2 + Vector2(0, 40), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.WHITE)

	# Draw counter display
	draw_counter_display(center)

func draw_counter_display(center: Vector2):
	var font = ThemeDB.fallback_font
	var font_size = 14
	var line_height = 18

	# Position counters to the right of the circle
	var counter_pos = center + Vector2(circle_radius + 40, -60)

	# Adjust background size based on combo mode
	var bg_height = 140
	if combo_enabled:
		bg_height = 180

	# Draw counter background
	var bg_rect = Rect2(counter_pos - Vector2(10, 10), Vector2(120, bg_height))
	draw_rect(bg_rect, Color(0, 0, 0, 0.7))
	draw_rect(bg_rect, Color.WHITE, false, 2)

	# Draw counter title
	draw_string(font, counter_pos, "QTE Stats", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size + 2, Color.WHITE)
	counter_pos.y += line_height + 5

	# Draw combo information if enabled
	if combo_enabled:
		var combo_text = "Combo: %d/%d" % [current_combo, combo_target]
		var combo_color = Color.YELLOW if current_combo > 0 else Color.GRAY
		draw_string(font, counter_pos, combo_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, combo_color)
		counter_pos.y += line_height

		# Draw combo progress bar
		var bar_width = 100
		var bar_height = 6
		var progress = float(current_combo) / float(combo_target)
		var bar_pos = counter_pos + Vector2(0, 2)

		# Background bar
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.DARK_GRAY)
		# Progress bar
		if progress > 0:
			var progress_width = bar_width * progress
			draw_rect(Rect2(bar_pos, Vector2(progress_width, bar_height)), Color.YELLOW)

		counter_pos.y += line_height

	# Draw total attempts
	var total_text = "Total: %d" % total_attempts
	draw_string(font, counter_pos, total_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	counter_pos.y += line_height

	# Draw perfect count
	var perfect_text = "Perfect: %d" % perfect_count
	draw_string(font, counter_pos, perfect_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, perfect_zone_color)
	counter_pos.y += line_height

	# Draw good count
	var good_text = "Good: %d" % good_count
	draw_string(font, counter_pos, good_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, good_zone_color)
	counter_pos.y += line_height

	# Draw miss count
	var miss_text = "Miss: %d" % miss_count
	draw_string(font, counter_pos, miss_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.GRAY)
	counter_pos.y += line_height + 5

	# Draw accuracy percentage
	var accuracy_percent = 0.0
	if total_attempts > 0:
		accuracy_percent = float(perfect_count + good_count) / float(total_attempts) * 100.0
	var accuracy_text = "Accuracy: %.1f%%" % accuracy_percent
	draw_string(font, counter_pos, accuracy_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.CYAN)

func draw_timing_zones(center: Vector2):
	# Convert angles to radians
	var target_rad = deg_to_rad(target_angle - 90)  # -90 to make 0° point up
	var perfect_half_angle = deg_to_rad(perfect_zone_angle / 2)
	var good_half_angle = deg_to_rad(good_zone_angle / 2)
	
	# Draw good zone (larger, behind perfect zone)
	draw_arc(center, circle_radius, 
		target_rad - good_half_angle, 
		target_rad + good_half_angle, 
		32, good_zone_color, circle_thickness + 4)
	
	# Draw perfect zone (smaller, on top)
	draw_arc(center, circle_radius, 
		target_rad - perfect_half_angle, 
		target_rad + perfect_half_angle, 
		32, perfect_zone_color, circle_thickness + 2)

func draw_indicator(center: Vector2):
	# Convert current angle to radians (-90 to make 0° point up)
	var angle_rad = deg_to_rad(current_angle - 90)
	
	# Calculate indicator line endpoints
	var inner_point = center + Vector2(cos(angle_rad), sin(angle_rad)) * (circle_radius - 15)
	var outer_point = center + Vector2(cos(angle_rad), sin(angle_rad)) * indicator_length
	
	# Draw the indicator line
	draw_line(inner_point, outer_point, indicator_color, indicator_thickness)
	
	# Draw a small circle at the tip
	draw_circle(outer_point, 4, indicator_color)

func _process(delta):
	if not is_active:
		return

	# Rotate the indicator continuously (never stop)
	current_angle += rotation_speed * delta

	# Keep angle in 0-360 range
	if current_angle >= 360:
		current_angle -= 360

	# Handle feedback timer
	if showing_feedback:
		feedback_timer -= delta
		if feedback_timer <= 0:
			showing_feedback = false
			# Reset indicator color
			indicator_color = Color.CYAN

	# Redraw
	queue_redraw()

func _input(event):
	if not is_active:
		return

	if event.is_action_pressed("playing"):  # Using existing spacebar input
		handle_input()

var feedback_timer: float = 0.0
var showing_feedback: bool = false
var last_result: TimingResult

func handle_input():
	# Don't allow input during feedback period
	if showing_feedback:
		return

	# Calculate timing accuracy
	var result = evaluate_timing()
	var accuracy = calculate_accuracy()

	# Update counters
	total_attempts += 1
	match result:
		TimingResult.PERFECT:
			perfect_count += 1
		TimingResult.GOOD:
			good_count += 1
		TimingResult.MISS:
			miss_count += 1

	# Handle combo system
	if combo_enabled:
		handle_combo_logic(result)

	# Emit result
	qte_result.emit(result, accuracy)

	# Show brief visual feedback but keep spinning
	show_result_feedback(result)

func evaluate_timing() -> TimingResult:
	var angle_diff = get_angle_difference(current_angle, target_angle)
	
	if angle_diff <= perfect_zone_angle / 2:
		return TimingResult.PERFECT
	elif angle_diff <= good_zone_angle / 2:
		return TimingResult.GOOD
	else:
		return TimingResult.MISS

func get_angle_difference(angle1: float, angle2: float) -> float:
	# Calculate the shortest angular distance between two angles
	var diff = abs(angle1 - angle2)
	if diff > 180:
		diff = 360 - diff
	return diff

func calculate_accuracy() -> float:
	# Return accuracy as percentage (100% = perfect, 0% = worst miss)
	var angle_diff = get_angle_difference(current_angle, target_angle)
	var max_diff = 180.0  # Maximum possible difference
	return max(0.0, (max_diff - angle_diff) / max_diff * 100.0)

func show_result_feedback(result: TimingResult):
	# Store result and start feedback timer
	last_result = result
	showing_feedback = true
	feedback_timer = 0.5  # Show feedback for 0.5 seconds

	# Change indicator color based on result
	match result:
		TimingResult.PERFECT:
			indicator_color = Color.GREEN
		TimingResult.GOOD:
			indicator_color = Color.YELLOW
		TimingResult.MISS:
			indicator_color = Color.RED

	queue_redraw()

func handle_combo_logic(result: TimingResult):
	"""Handle combo/streak logic and check for completion"""
	var is_successful_hit = false

	# Determine if this counts as a successful hit for combo
	if combo_requires_perfect:
		is_successful_hit = (result == TimingResult.PERFECT)
	else:
		is_successful_hit = (result == TimingResult.PERFECT or result == TimingResult.GOOD)

	if is_successful_hit:
		current_combo += 1

		# Check if combo target reached
		if current_combo >= combo_target:
			# Combo completed! End the QTE
			var perfect_in_combo = 0
			var good_in_combo = 0

			# Calculate hits in this combo (simplified - could be more detailed)
			if combo_requires_perfect:
				perfect_in_combo = current_combo
			else:
				# Estimate based on recent performance
				perfect_in_combo = min(current_combo, perfect_count)
				good_in_combo = current_combo - perfect_in_combo

			combo_completed.emit(current_combo, perfect_in_combo, good_in_combo)
			end_qte_with_combo_success()
	else:
		# Miss breaks the combo
		if current_combo > 0:
			combo_broken.emit(current_combo)
		current_combo = 0

func end_qte_with_combo_success():
	"""End the QTE when combo target is reached"""
	is_active = false
	showing_feedback = true
	feedback_timer = 2.0  # Show success feedback longer

	# Change indicator to success color
	indicator_color = Color.GOLD

	print("QTE Completed! Combo target of %d reached!" % combo_target)

func start_qte():
	is_active = true
	current_angle = 180.0  # Start at bottom
	indicator_color = Color.CYAN
	showing_feedback = false
	feedback_timer = 0.0
	current_combo = 0  # Reset combo when starting
	queue_redraw()

func restart_qte():
	start_qte()

func reset_counters():
	"""Reset all counters to zero"""
	perfect_count = 0
	good_count = 0
	miss_count = 0
	total_attempts = 0
	current_combo = 0
	queue_redraw()

# Combo system functions
func enable_combo_mode(target: int, perfect_only: bool = false):
	"""Enable combo mode with specified target and requirements"""
	combo_enabled = true
	combo_target = target
	combo_requires_perfect = perfect_only
	current_combo = 0
	print("Combo mode enabled: %d %s hits required" % [target, "perfect" if perfect_only else "successful"])

func disable_combo_mode():
	"""Disable combo mode and return to continuous mode"""
	combo_enabled = false
	current_combo = 0
	print("Combo mode disabled")

func get_combo_progress() -> float:
	"""Get combo progress as percentage (0.0 to 1.0)"""
	if not combo_enabled or combo_target <= 0:
		return 0.0
	return float(current_combo) / float(combo_target)

func set_difficulty(speed_multiplier: float):
	# Adjust difficulty by changing rotation speed
	rotation_speed = 180.0 * speed_multiplier

func set_timing_zones(perfect_degrees: float, good_degrees: float):
	# Allow customization of timing zone sizes
	perfect_zone_angle = perfect_degrees
	good_zone_angle = good_degrees

func _on_qte_result(result: TimingResult, accuracy: float):
	# Integration with existing scoring system
	if not Manager:
		return

	match result:
		TimingResult.PERFECT:
			Manager.increment_score.emit(250)  # Same as existing perfect score
			Manager.increment_combo.emit()
			print("QTE: PERFECT! Accuracy: %.1f%%" % accuracy)
		TimingResult.GOOD:
			Manager.increment_score.emit(100)  # Same as existing great score
			Manager.increment_combo.emit()
			print("QTE: GOOD! Accuracy: %.1f%%" % accuracy)
		TimingResult.MISS:
			Manager.reset_combo.emit()
			print("QTE: MISS! Accuracy: %.1f%%" % accuracy)

# Additional utility functions for advanced usage

func stop_qte():
	"""Stop the QTE without triggering a result"""
	is_active = false

func pause_qte():
	"""Pause the QTE rotation"""
	is_active = false

func resume_qte():
	"""Resume the QTE rotation"""
	is_active = true

func get_current_timing_zone() -> TimingResult:
	"""Get the current timing zone the indicator is in"""
	return evaluate_timing()

func set_target_position(angle_degrees: float):
	"""Set where the target zone should be positioned (0° = top, 90° = right, etc.)"""
	target_angle = angle_degrees
	queue_redraw()

# Preset difficulty configurations
func set_easy_difficulty():
	set_difficulty(0.5)  # Half speed
	set_timing_zones(20.0, 40.0)  # Larger timing windows

func set_normal_difficulty():
	set_difficulty(1.0)  # Normal speed
	set_timing_zones(15.0, 30.0)  # Default timing windows

func set_hard_difficulty():
	set_difficulty(1.5)  # 1.5x speed
	set_timing_zones(10.0, 20.0)  # Smaller timing windows

func set_expert_difficulty():
	set_difficulty(2.0)  # 2x speed
	set_timing_zones(8.0, 15.0)  # Very small timing windows
