extends Timer

var bpm: float = 120
var delay: float = 60 / bpm


var playing = false
var index = 0

func _ready():
	print(delay)

func _input(event):
	if Input.is_action_just_pressed("playing"):
		playing = !playing
		if playing:
			start()

func _on_timeout() -> void:
	get_node("../track").get_children()[index].color.a = 1
	if get_node("../track").get_children()[index - 1].color.g == 0:
		get_node("../track").get_children()[index - 1].color.a = 0

	if playing:
		start()
		index += 1
		return
	
	stop()
	index = 0
	
