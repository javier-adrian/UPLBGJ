extends Node2D

func _ready():
    # Make sure the StartMenu is connected to this script
    if $StartMenu.is_connected("play", Callable(self, "_on_start_menu_play")):
        print("StartMenu play signal is connected")
    else:
        print("StartMenu play signal is NOT connected")
        $StartMenu.connect("play", Callable(self, "_on_start_menu_play"))

func _input(event):
    if Input.is_action_just_pressed("producer"):
        get_tree().change_scene_to_file("res://scenes/producer/producer.tscn")

func _on_start_menu_play() -> void:
    print("Play signal received")
    
    # Check if the animation player exists
    if $background.has_node("AnimationPlayer"):
        $background/AnimationPlayer.play("zoom_out")
    else:
        print("Background AnimationPlayer not found")
    
    if $StartMenu.has_node("AnimationPlayer"):
        $StartMenu/AnimationPlayer.play("play")
        
        # Wait for animation to finish before changing scene
        await $StartMenu/AnimationPlayer.animation_finished
        print("Animation finished, changing to level scene")
        get_tree().change_scene_to_file("res://scenes/level/level.tscn")
    else:
        print("StartMenu AnimationPlayer not found")
        # If no animation player, just change scene directly
        get_tree().change_scene_to_file("res://scenes/level/level.tscn")


