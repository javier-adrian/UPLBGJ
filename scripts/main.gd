extends Node2D

var level1 = preload("res://scenes/level/level.tscn")
var start_menu_scene = preload("res://scenes/StartMenu/StartMenu.tscn")

func _ready():
	# Add to main_scene group for easy access
	add_to_group("main_scene")

	# Ensure StartMenu exists (in case it was missing)
	ensure_start_menu_exists()

	# Check if we're returning from a game
	if Manager.returning_from_game:
		reset_main_menu_state()
		Manager.returning_from_game = false

func _input(_event):
	if Input.is_action_just_pressed("producer"):
		get_tree().change_scene_to_file("res://scenes/producer/producer.tscn")

func reset_main_menu_state():
	print("=== RESETTING MAIN MENU STATE ===")

	# Remove any level instance that might be running
	if has_node("level_instance"):
		print("Removing existing level instance")
		$level_instance.queue_free()

	# Ensure StartMenu exists first
	ensure_start_menu_exists()

	# Make sure the background is visible and reset
	if has_node("background"):
		print("Setting background visible")
		$background.visible = true
		print("Background visible state: ", $background.visible)

		# Reset background to zoomed in state
		if $background.has_method("switch") and not $background.zoomed_in:
			print("Resetting background to zoomed in state")
			$background.switch()

		# Also reset the animation to RESET state
		if has_node("background/AnimationPlayer"):
			print("Resetting background animation to RESET")
			$background/AnimationPlayer.play("RESET")
	else:
		print("Background node not found!")

	# Make sure the start menu is visible and on top
	if has_node("StartMenu"):
		print("Setting StartMenu visible")
		$StartMenu.visible = true
		print("StartMenu visible state: ", $StartMenu.visible)

		# Make sure StartMenu is on top of other elements
		move_child($StartMenu, -1)
		print("StartMenu moved to front")

		# Check StartMenu's modulate (transparency)
		print("StartMenu modulate: ", $StartMenu.modulate)
		$StartMenu.modulate = Color.WHITE  # Ensure it's not transparent
		print("StartMenu modulate reset to white")

		# Reset StartMenu animation to RESET state
		if has_node("StartMenu/AnimationPlayer"):
			print("Resetting StartMenu animation")
			$StartMenu/AnimationPlayer.stop()
			$StartMenu/AnimationPlayer.play("RESET")
			print("StartMenu animation reset to RESET")
	else:
		print("StartMenu node STILL not found after ensure!")

	# Reset any animations or states
	if has_node("gameplay_background/AnimationPlayer"):
		print("Resetting gameplay background animation")
		$gameplay_background/AnimationPlayer.stop()
		$gameplay_background/AnimationPlayer.play("RESET")
	else:
		print("Gameplay background AnimationPlayer not found!")

	print("=== MAIN MENU STATE RESET COMPLETE ===")

# Function to create StartMenu if it doesn't exist
func ensure_start_menu_exists():
	print("=== ENSURING START MENU EXISTS ===")

	if not has_node("StartMenu"):
		print("StartMenu not found, creating new instance")

		# Create new StartMenu instance
		var start_menu_instance = start_menu_scene.instantiate()
		start_menu_instance.name = "StartMenu"

		# Add it to the scene
		add_child(start_menu_instance)
		print("StartMenu instance created and added")

		# Connect the signals
		if start_menu_instance.has_signal("play"):
			start_menu_instance.play.connect(_on_start_menu_play)
			print("Connected play signal")

		if start_menu_instance.has_signal("about"):
			start_menu_instance.about.connect(_on_start_menu_about)
			print("Connected about signal")

		if start_menu_instance.has_signal("how_to_play"):
			start_menu_instance.how_to_play.connect(_on_start_menu_how_to_play)
			print("Connected how_to_play signal")

		if start_menu_instance.has_signal("credits"):
			start_menu_instance.credits.connect(_on_start_menu_credits)
			print("Connected credits signal")

		print("StartMenu signals connected")
	else:
		print("StartMenu already exists")

	print("=== START MENU ENSURED ===")

# Function to restart the level (called from end screen)
func restart_level():
	print("=== RESTART LEVEL CALLED ===")

	# Remove existing level instance if it exists
	if has_node("level_instance"):
		print("Removing existing level instance")
		var old_level = get_node("level_instance")

		# Stop music if it's playing
		if old_level.has_node("editor/Player"):
			var player = old_level.get_node("editor/Player")
			if player.playing:
				print("Stopping music player")
				player.stop()

		# Remove the level
		remove_child(old_level)
		old_level.queue_free()
		print("Old level removed")

	# Wait a frame for cleanup
	await get_tree().process_frame

	# Create new level instance
	print("Creating new level instance...")
	var level_instance = level1.instantiate()
	level_instance.name = "level_instance"
	add_child(level_instance)
	print("New level instance created and added")

	print("=== RESTART LEVEL COMPLETE ===")

# Function to return to main menu (called from end screen)
func return_to_menu():
	print("=== RETURN TO MENU CALLED ===")

	# Remove existing level instance if it exists
	if has_node("level_instance"):
		print("Removing level instance")
		var old_level = get_node("level_instance")

		# Stop music if it's playing
		if old_level.has_node("editor/Player"):
			var player = old_level.get_node("editor/Player")
			if player.playing:
				print("Stopping music player")
				player.stop()

		# Remove the level
		remove_child(old_level)
		old_level.queue_free()
		print("Level removed")

	# Wait a frame for cleanup
	await get_tree().process_frame

	# Ensure StartMenu exists (recreate if destroyed by play animation)
	ensure_start_menu_exists()

	# Show the start menu again
	if has_node("StartMenu"):
		print("Making StartMenu visible")
		get_node("StartMenu").visible = true
		print("StartMenu visible state: ", get_node("StartMenu").visible)

		# Make sure StartMenu is on top
		move_child(get_node("StartMenu"), -1)
		print("StartMenu moved to front")
	else:
		print("StartMenu node STILL not found after recreation!")

	# Reset main menu state
	reset_main_menu_state()

	# Debug: Print all children and their visibility
	print("Main scene children after return to menu:")
	for child in get_children():
		print("  - ", child.name, " visible: ", child.visible if child.has_method("set_visible") else "N/A")

	print("=== RETURN TO MENU COMPLETE ===")

func _on_start_menu_play() -> void:
	print("=== PLAY BUTTON PRESSED ===")

	# Debug: Check initial states
	print("Background visible: ", $background.visible if has_node("background") else "No background node")
	print("StartMenu visible: ", $StartMenu.visible if has_node("StartMenu") else "No StartMenu node")
	print("Gameplay background position: ", $gameplay_background.position if has_node("gameplay_background") else "No gameplay_background node")
	print("Gameplay background scale: ", $gameplay_background.scale if has_node("gameplay_background") else "No gameplay_background node")

	# Show the background for the transition
	if has_node("background"):
		print("Making background visible for transition")
		$background.visible = true
		print("Background visible after setting: ", $background.visible)

		# Trigger the background zoom out animation
		if $background.has_method("switch"):
			print("Triggering background switch animation")
			$background.switch()
		else:
			print("Background switch method not found")

	# Check animation players
	if has_node("gameplay_background/AnimationPlayer"):
		print("Gameplay AnimationPlayer found, available animations: ", $gameplay_background/AnimationPlayer.get_animation_library("").get_animation_list())
		print("Current animation: ", $gameplay_background/AnimationPlayer.current_animation)
	else:
		print("Gameplay AnimationPlayer NOT found!")

	if has_node("StartMenu/AnimationPlayer"):
		print("StartMenu AnimationPlayer found, available animations: ", $StartMenu/AnimationPlayer.get_animation_library("").get_animation_list())
		print("Current animation: ", $StartMenu/AnimationPlayer.current_animation)
	else:
		print("StartMenu AnimationPlayer NOT found!")

	# Start the animations
	print("Starting zoom out animation")
	if has_node("gameplay_background/AnimationPlayer"):
		$gameplay_background/AnimationPlayer.play("zoom_out")
		print("Zoom out animation started")

	if has_node("StartMenu/AnimationPlayer"):
		$StartMenu/AnimationPlayer.play("play")
		print("StartMenu play animation started")

	# Wait for animations to complete
	print("Waiting for animations to complete...")
	await get_tree().create_timer(2).timeout
	print("Animation sequence complete, instantiating level")

	# Debug: Check final states
	print("Final background visible: ", $background.visible if has_node("background") else "No background node")
	print("Final gameplay background position: ", $gameplay_background.position if has_node("gameplay_background") else "No gameplay_background node")
	print("Final gameplay background scale: ", $gameplay_background.scale if has_node("gameplay_background") else "No gameplay_background node")

	# Hide the start menu
	if has_node("StartMenu"):
		$StartMenu.visible = false
		print("StartMenu hidden")

	# Instantiate the level as a child (preserving background)
	print("Instantiating level...")
	var level_instance = level1.instantiate()
	level_instance.name = "level_instance"  # Give it a specific name for cleanup
	add_child(level_instance)
	print("Level instantiated and added as child")

func _on_start_menu_about() -> void:
	print("Main received About signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/About/About.tscn")

func _on_start_menu_how_to_play() -> void:
	print("Main received How to Play signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/HowToPlay/HowToPlay.tscn")

func _on_start_menu_credits() -> void:
	print("Main received Credits signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/Credits/Credits.tscn")



	
