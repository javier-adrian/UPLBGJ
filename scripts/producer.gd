extends CanvasLayer

func _ready():
	$tracks/track.get_children().map(
		func(child): child.color.a = int(!child.color == Color.RED))


func _input(event):
	if Input.is_action_just_pressed("producer"):
		get_tree().change_scene_to_file("res://scenes/Main/main.tscn")

	
