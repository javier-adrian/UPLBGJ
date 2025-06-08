extends Control

var score: int = 0
var combo: int = 0
var combo_multiplier: float = 1.0
var combo_threshold: int = 5  # Combo needed for multiplier

func _ready():
	Manager.increment_score.connect(increment_score)
	Manager.increment_combo.connect(increment_combo)
	Manager.reset_combo.connect(reset_combo)

func increment_score(n: int):
	var points = n
	if combo >= combo_threshold:
		points = int(n*combo_multiplier)
	score += points
	%score.text = str(score)


func increment_combo():
	combo += 1
	%combo.text = str(combo)
	
	if combo >= combo_threshold:
		%combo.text = str(combo) + " (x" + str(combo_multiplier) + ")"
	else:
		%combo.text = str(combo)
	
	if combo == combo_threshold:
		combo_multiplier = 1.5
	elif combo > combo_threshold:
		combo_multiplier = min(1.5 + (combo - combo_threshold) * 0.1, 3.0)

func reset_combo():
	combo = 0
	%combo.text = str(combo)