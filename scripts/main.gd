extends Node2D

var level1 = preload("res://scenes/level/level.tscn")

func _input(event):
	if Input.is_action_just_pressed("producer"):
		get_tree().change_scene_to_file("res://scenes/producer/producer.tscn")

func _on_start_menu_play() -> void:
	$gameplay_background/AnimationPlayer.play("zoom_out")
	$StartMenu/AnimationPlayer.play("play")
	await get_tree().create_timer(2).timeout
	# print(get_children())
	# $background.queue_free()
	var level_instance = level1.instantiate()
	get_tree().root.call_deferred("add_child", level_instance)
	$gameplay_background/AnimationPlayer.play("crowd")

func _on_start_menu_about() -> void:
	print("Main received About signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/About/About.tscn")

func _on_start_menu_how_to_play() -> void:
	print("Main received How to Play signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/HowToPlay/HowToPlay.tscn")

func _on_start_menu_credits() -> void:
	print("Main received Credits signal - changing scene")
	get_tree().change_scene_to_file("res://scenes/Credits/Credits.tscn")



	
