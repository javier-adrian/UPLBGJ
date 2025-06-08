extends Control

signal play()
signal how_to_play()
signal about()
signal credits()

func _on_play_button_down() -> void:
	# First emit the signal for the main scene to handle
	play.emit()
	
# 	# If we're not in the main scene or the signal isn't connected,
# 	# directly change to the level scene after a short delay
# 	var timer = get_tree().create_timer(0.5)
# 	await timer.timeout
	
# 	# Check if we're still in the same scene (signal wasn't handled)
# 	if is_instance_valid(self) and is_inside_tree():
# 		get_tree().change_scene_to_file("res://scenes/level/level.tscn")


func _on_quit_button_down() -> void:
	get_tree().quit()


func _on_how_to_play_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/HowToPlay/HowToPlay.tscn")


func _on_about_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/About/About.tscn")


func _on_credits_button_down() -> void:
	get_tree().change_scene_to_file("res://scenes/Credits/Credits.tscn")


# Alternative direct method if signal approach doesn't work
func play_game_direct() -> void:
	pass
	# get_tree().change_scene_to_file("res://scenes/level/level.tscn")

# You can call this from the editor by connecting the pressed signal
# to this method instead of button_down to _on_play_button_down
func _on_play_pressed() -> void:
	pass
	# play_game_direct()
