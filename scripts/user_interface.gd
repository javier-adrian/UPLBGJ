extends Control

var score: int = 0

func _ready():
	Manager.increment_score.connect(increment_score)

func increment_score(n: int):
	score += n
	%score.text = str(score)
