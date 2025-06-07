extends Control

var score: int = 0
var combo: int = 0

func _ready():
	Manager.increment_score.connect(increment_score)
	Manager.increment_combo.connect(increment_combo)
	Manager.reset_combo.connect(reset_combo)
	# await get_tree().create_timer(3).timeout
	# $RhythmHell.play()

func increment_score(n: int):
	score += n
	%score.text = str(score)


func increment_combo():
	combo += 1
	%combo.text = str(combo)

func reset_combo():
	combo = 0
	%combo.text = str(combo)
