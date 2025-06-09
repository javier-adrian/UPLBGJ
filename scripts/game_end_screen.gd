extends Control

var is_success: bool = false
var final_score: int = 0
var perfect_count: int = 0
var great_count: int = 0
var good_count: int = 0
var uninstall_count: int = 0
var miss_count: int = 0
var final_spirit: float = 0.0

# Function to clear the scene when game ends
func clear_game_scene():
	print("Clearing game scene...")

	# Clean up listener queues FIRST (before freeing notes)
	for listener in get_tree().get_nodes_in_group("listeners"):
		if listener.has_method("cleanup_queue"):
			listener.cleanup_queue()

	# Stop all audio
	var audio_players = get_tree().get_nodes_in_group("audio")
	for player in audio_players:
		if player.has_method("stop"):
			player.stop()

	# Clean up all notes
	for note in get_tree().get_nodes_in_group("notes"):
		if is_instance_valid(note):
			note.queue_free()

	# Stop any timers or spawners
	var spawners = get_tree().get_nodes_in_group("spawners")
	for spawner in spawners:
		if spawner.has_method("stop_spawning"):
			spawner.stop_spawning()

	# Pause the game to prevent further updates
	get_tree().paused = true

	# Wait for next frame to ensure cleanup is processed
	await get_tree().process_frame

func _ready():
	# Connect to Manager signals
	Manager.game_success.connect(_on_game_success)
	Manager.game_failure.connect(_on_game_failure)

	# Initially hide the end screen
	visible = false

	# Debug: Print scene tree info
	print("End screen _ready() called")
	if get_tree().current_scene:
		print("Current scene: ", get_tree().current_scene.name)
	else:
		print("Current scene: None")
	print("Root children count: ", get_tree().root.get_child_count())
	for child in get_tree().root.get_children():
		print("  - Root child: ", child.name, " (", child.get_class(), ")")

func _input(event):
	if visible and event is InputEventMouseButton and event.pressed:
		print("Mouse click detected on end screen at: ", event.position)
		# Check if click is on main menu button
		var button_rect = %MainMenuButton.get_global_rect()
		if button_rect.has_point(event.global_position):
			print("Click was on main menu button area!")
			print("Button rect: ", button_rect)
			print("Click position: ", event.global_position)

	# Test shortcut for main menu (press M key)
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_M:
		print("M key pressed - triggering main menu function manually")
		_on_main_menu_button_pressed()

func _exit_tree():
	# Reset the Manager variable when this instance is freed
	Manager.end_screen_showing = false

func show_results(success: bool, score: int, perfect: int, great: int, good: int, uninstall: int, misses: int, spirit: float):
	# Prevent multiple end screens from showing
	print("show_results called, Manager.end_screen_showing = ", Manager.end_screen_showing)
	if Manager.end_screen_showing:
		print("End screen already showing, ignoring duplicate call")
		return

	print("Setting Manager.end_screen_showing = true")
	Manager.end_screen_showing = true
	is_success = success
	final_score = score
	perfect_count = perfect
	great_count = great
	good_count = good
	uninstall_count = uninstall
	miss_count = misses
	final_spirit = spirit

	# Update the WIN/LOSE label
	if is_success:
		%WinLabel.text = "WIN"
		%WinLabel.modulate = Color.GREEN
		%NewsContent.text = "(THIS IS A PLACEHOLDER FOR THE IMAGE)\n\nGame completed successfully!\n\nYour performance was excellent.\n\nThanks for playing!"
	else:
		%WinLabel.text = "LOSE"
		%WinLabel.modulate = Color.RED
		%NewsContent.text = "(THIS IS A PLACEHOLDER FOR THE IMAGE)\n\nGame Over! Don't give up!\n\nPractice makes perfect in rhythm games.\n\nTry again and improve your timing!"

	# Update score (separate label and number)
	%ScoreNumber.text = str(final_score).pad_zeros(2)

	# Update stats using separate number labels
	%PerfectNumber.text = str(perfect_count).pad_zeros(2)
	%GreatNumber.text = str(great_count).pad_zeros(2)
	%GoodNumber.text = str(good_count).pad_zeros(2)
	%UninstallNumber.text = str(uninstall_count).pad_zeros(2)
	%MissesNumber.text = str(miss_count).pad_zeros(2)
	%SpiritNumber.text = str(int(final_spirit)).pad_zeros(2) + "%"

	# Show the end screen
	visible = true

	# Make sure buttons are enabled
	%RetryButton.disabled = false
	%MainMenuButton.disabled = false
	print("End screen shown, buttons enabled")
	print("Retry button disabled: ", %RetryButton.disabled)
	print("Main menu button disabled: ", %MainMenuButton.disabled)
	print("Retry button visible: ", %RetryButton.visible)
	print("Main menu button visible: ", %MainMenuButton.visible)

	# Test button connections
	if %MainMenuButton.pressed.is_connected(_on_main_menu_button_pressed):
		print("Main menu button is connected")
	else:
		print("Main menu button is NOT connected!")
		# Try to connect manually
		%MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
		print("Manually connected main menu button")

func _on_game_success():
	print("Game success detected - clearing scene")
	# Clear the scene first
	clear_game_scene()

	# Get stats from the user interface
	var ui = get_tree().get_nodes_in_group("user_interface")
	if ui.size() > 0:
		var score = ui[0].score
		var _combo = ui[0].combo  # Prefixed with _ to avoid unused variable warning
		var spirit = ui[0].get_node("%spirit").value

		# Get real hit data from Manager
		var perfect = Manager.perfect_count
		var great = Manager.great_count
		var good = Manager.good_count
		var uninstall = Manager.uninstall_count
		var misses = Manager.miss_count

		# Print final stats for debugging
		Manager.print_hit_stats()

		# Wait a moment before showing results
		await get_tree().create_timer(1.0).timeout
		show_results(true, score, perfect, great, good, uninstall, misses, spirit)

func _on_game_failure():
	print("Game failure detected - clearing scene")
	# Clear the scene first
	clear_game_scene()

	# Get stats from the user interface
	var ui = get_tree().get_nodes_in_group("user_interface")
	if ui.size() > 0:
		var score = ui[0].score
		var _combo = ui[0].combo  # Prefixed with _ to avoid unused variable warning
		var spirit = ui[0].get_node("%spirit").value

		# Get real hit data from Manager
		var perfect = Manager.perfect_count
		var great = Manager.great_count
		var good = Manager.good_count
		var uninstall = Manager.uninstall_count
		var misses = Manager.miss_count

		# Print final stats for debugging
		Manager.print_hit_stats()

		# Wait a moment before showing results
		await get_tree().create_timer(1.0).timeout
		show_results(false, score, perfect, great, good, uninstall, misses, spirit)

func _on_retry_button_pressed():
	print("RETRY BUTTON PRESSED!")
	# Reset the Manager variable
	print("Setting Manager.end_screen_showing = false")
	Manager.end_screen_showing = false

	# Disable buttons to prevent multiple clicks
	%RetryButton.disabled = true
	%MainMenuButton.disabled = true

	# Unpause the tree before changing scenes
	get_tree().paused = false

	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		if is_instance_valid(note):
			note.queue_free()

	# Clean up listener queues
	for listener in get_tree().get_nodes_in_group("listeners"):
		if listener.has_method("cleanup_queue"):
			listener.cleanup_queue()

	# Clean up any level instances that might be hanging around
	for child in get_tree().root.get_children():
		if child.name.begins_with("level") and child != get_tree().current_scene:
			print("Removing orphaned level instance: ", child.name)
			child.queue_free()

	# Wait a frame to ensure cleanup
	await get_tree().process_frame

	# Use a deferred call to restart from the main scene
	print("=== RESTARTING FIRST LEVEL ===")
	print("Using deferred restart approach")

	# Unpause the tree
	get_tree().paused = false

	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		if is_instance_valid(note):
			note.queue_free()

	# Clean up listener queues
	for listener in get_tree().get_nodes_in_group("listeners"):
		if listener.has_method("cleanup_queue"):
			listener.cleanup_queue()

	# Find the main scene and ask it to restart the level
	var main_scene = get_tree().get_nodes_in_group("main_scene")
	if main_scene.size() > 0:
		print("Found main scene, requesting restart")
		# Use call_deferred to avoid issues with the current execution context
		main_scene[0].call_deferred("restart_level")
	else:
		print("Main scene not found, falling back to scene change")
		get_tree().change_scene_to_file("res://scenes/level/level.tscn")

func _on_main_menu_button_pressed():
	print("=== MAIN MENU BUTTON PRESSED! ===")
	print("Button disabled state: ", %MainMenuButton.disabled)
	print("Button visible state: ", %MainMenuButton.visible)
	print("End screen visible: ", visible)

	# Reset the Manager variable
	print("Setting Manager.end_screen_showing = false")
	Manager.end_screen_showing = false

	# Disable buttons to prevent multiple clicks
	%RetryButton.disabled = true
	%MainMenuButton.disabled = true
	print("Buttons disabled for transition")

	# Unpause the tree before changing scenes
	get_tree().paused = false

	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		if is_instance_valid(note):
			note.queue_free()

	# Clean up listener queues
	for listener in get_tree().get_nodes_in_group("listeners"):
		if listener.has_method("cleanup_queue"):
			listener.cleanup_queue()

	# Clean up any level instances that might be hanging around
	for child in get_tree().root.get_children():
		if child.name.begins_with("level") and child != get_tree().current_scene:
			print("Removing orphaned level instance: ", child.name)
			child.queue_free()

	# Wait a frame to ensure cleanup
	await get_tree().process_frame

	# Return to main menu state using deferred call
	print("Returning to main menu...")

	# Unpause the tree
	get_tree().paused = false

	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		if is_instance_valid(note):
			note.queue_free()

	# Clean up listener queues
	for listener in get_tree().get_nodes_in_group("listeners"):
		if listener.has_method("cleanup_queue"):
			listener.cleanup_queue()

	# Find the main scene and ask it to return to menu
	var main_scene = get_tree().get_nodes_in_group("main_scene")
	if main_scene.size() > 0:
		print("Found main scene, requesting return to menu")
		# Use call_deferred to avoid issues with the current execution context
		main_scene[0].call_deferred("return_to_menu")
	else:
		print("Main scene not found, falling back to scene change")
		# Set flag to indicate we're returning from game
		Manager.returning_from_game = true
		var result = get_tree().change_scene_to_file("res://scenes/Main/main.tscn")
		print("Scene change result: ", result)
