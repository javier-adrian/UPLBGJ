extends Control

# Textures for success and failure
@export var success_texture: Texture2D
@export var failure_texture: Texture2D

# Game stats
var final_score: int = 0
var max_combo: int = 0
var final_spirit: float = 0
var is_success: bool = false

func _ready():
	# Connect to game result signals
	Manager.game_success.connect(_on_game_success)
	Manager.game_failure.connect(_on_game_failure)
	
	# Set default textures if not assigned in editor
	#if success_texture == null:
		#success_texture = preload("res://path_to_success_image.png")
	#if failure_texture == null:
		#failure_texture = preload("res://path_to_failure_image.png")
	
	# Make sure this control is not affected by pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide this screen initially if used in the same scene
	visible = false

func show_results(success: bool, score: int, combo: int, spirit: float):
	is_success = success
	final_score = score
	max_combo = combo
	final_spirit = spirit
	
	# Update UI elements
	if is_success:
		%ResultSprite.texture = success_texture
		%ResultLabel.text = "SUCCESS!"
		%ResultLabel.modulate = Color.GREEN
	else:
		%ResultSprite.texture = failure_texture
		%ResultLabel.text = "FAILURE!"
		%ResultLabel.modulate = Color.RED
	
	%ScoreLabel.text = "SCORE: " + str(final_score)
	%MaxComboLabel.text = "MAX COMBO: " + str(max_combo)
	%SpiritLabel.text = "FINAL SPIRIT: " + str(int(final_spirit)) + "%"
	
	# Show the end screen
	visible = true

func _on_game_success():
	# Get stats from the user interface
	var ui = get_tree().get_nodes_in_group("user_interface")
	if ui.size() > 0:
		var score = ui[0].score
		var combo = ui[0].combo
		var spirit = ui[0].get_node("%spirit").value
		
		# Wait a moment before showing results
		await get_tree().create_timer(1.0).timeout
		show_results(true, score, combo, spirit)

func _on_game_failure():
	# Get stats from the user interface
	var ui = get_tree().get_nodes_in_group("user_interface")
	if ui.size() > 0:
		var score = ui[0].score
		var combo = ui[0].combo
		var spirit = ui[0].get_node("%spirit").value
		
		# Wait a moment before showing results
		await get_tree().create_timer(1.0).timeout
		show_results(false, score, combo, spirit)

func _on_retry_button_pressed():
	# Unpause the tree before changing scenes
	get_tree().paused = false
	
	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		note.queue_free()
	
	# Reload the current level
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	# Unpause the tree before changing scenes
	get_tree().paused = false
	
	# Clean up any remaining notes
	for note in get_tree().get_nodes_in_group("notes"):
		note.queue_free()
	
	# Go back to main menu
	get_tree().change_scene_to_file("res://scenes/StartMenu/StartMenu.tscn")
