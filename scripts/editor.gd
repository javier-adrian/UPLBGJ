extends Node2D

var editing: bool = false
var title: String = "Rhythm Hell"

var info: Dictionary = {
	"Rhythm Hell": {
		"timings":  "[[1, 3],[1.5, 3.5],[2, 4],[2.5, 4.5]]",
		"music": load("res://RhythmHell.wav")
	}
}

func _ready():
	$Player.stream = info.get(title).get("music")
	$Player.play()

	if editing:
		Manager.listener_press.connect(listener_press)
	else:
		var timings = info.get(title).get("timings")
		var timings_array = str_to_var(timings)

		var index: int = 0

		for key in timings_array:
			var key_name: String = ""

			match index:
				0:
					key_name = "left"
				1:
					key_name = "up"
				2:
					key_name = "down"
				3:
					key_name = "right"

			for delay in key:
				spawn_note(key_name, delay)
			
			index += 1

func listener_press(key: String, index: int):
	print(index)

func spawn_note(key: String, delay: float):
	await get_tree().create_timer(delay).timeout
	Manager.spawn_note.emit(key)
