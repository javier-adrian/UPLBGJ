extends Control

var score: int = 0
var combo: int = 0
var spirit_started: bool = false
var combo_multiplier: float = 1.0
var combo_threshold: int = 5  # Combo needed for multiplier
var game_ended: bool = false  # Track if game has already ended

func _ready():
	Manager.increment_score.connect(increment_score)
	Manager.increment_combo.connect(increment_combo)
	Manager.reset_combo.connect(reset_combo)
	Manager.increment_spirit.connect(increment_spirit)
	Manager.decrement_spirit.connect(decrement_spirit)
	# await get_tree().create_timer(3).timeout
	# $RhythmHell.play()

func _process(delta):
	if spirit_started and !game_ended:
		%spirit.value -= 0.01
		
		# Check for success condition
		if %spirit.value >= 100:
			game_ended = true
			Manager.game_success.emit()
			print("Success! Spirit reached 100!")
		
		# Check for failure condition (spirit depleted)
		elif %spirit.value <= 0:
			game_ended = true
			Manager.game_failure.emit()
			print("Failure! Spirit depleted!")

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

func increment_spirit(value: float):
	%spirit.value += value

	if !spirit_started:
		spirit_started = true

func decrement_spirit(value: float):
	if spirit_started:
		%spirit.value -= value

# Connect to song end (call this from your song player)
func on_song_finished():
	if !game_ended:
		if %spirit.value >= 50:  # Optional: require at least half spirit to succeed
			Manager.game_success.emit()
			print("Success! Song completed with sufficient spirit!")
		else:
			Manager.game_failure.emit()
			print("Failure! Song completed with insufficient spirit!")
		game_ended = true
