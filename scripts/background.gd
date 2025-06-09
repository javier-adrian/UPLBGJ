extends Node2D

var zoomed_in: bool = true

func switch():
	print("Background switch called, zoomed_in = ", zoomed_in)
	if zoomed_in:
		print("Playing zoom_out animation")
		$AnimationPlayer.play("zoom_out")
		zoomed_in = false
	else:
		print("Playing zoom_in animation")
		$AnimationPlayer.play("zoom_in")
		zoomed_in = true
	print("Background zoomed_in state after switch: ", zoomed_in)