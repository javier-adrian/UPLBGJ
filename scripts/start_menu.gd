extends Control

signal play()

func _on_play_button_down() -> void:
	play.emit()


func _on_quit_button_down() -> void:
	get_tree().quit()
