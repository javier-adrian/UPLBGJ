extends Node2D

var zoomed_in: bool = true

func switch():
	if zoomed_in:
		$AnimationPlayer.play("zoom_out")
	else:
		$AnimationPlayer.play("zoom_in")
