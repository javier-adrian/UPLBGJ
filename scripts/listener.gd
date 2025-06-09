extends Node2D

@onready var note = preload("res://scenes/note/note.tscn")
@onready var rating = preload("res://scenes/rating/rating.tscn")
@export var key: String = ""
@export var index: int = 0

@onready var sfx: Dictionary = {
	"left": load("res://assets/audio/A Key - Laban.wav"),
	"up": load("res://assets/audio/S Key - Clap.wav"),
	"down": load("res://assets/audio/D Key - Stomp.wav"),
	"right": load("res://assets/audio/F Key Alternate - Woooh.wav")
}

var frame_index: Dictionary = {
	"left": 16,
	"up": 34,
	"down": 19,
	"right": 21
}

var queue = []

var distance_perfect: float = 5
var distance_great: float = 10
var distance_good: float = 20
var distance_uninstall: float = 40

var score_perfect: float = 250
var score_great: float = 100
var score_good: float = 50
var score_uninstall: float = 20

func _ready():
	# Add to listeners group for cleanup
	add_to_group("listeners")
	Manager.spawn_note.connect(spawn_note)
	%sfx.stream = sfx.get(key)
	$sprite.frame = frame_index.get(key)

func _input(event):
	if Input.is_action_just_pressed(key):
		Manager.listener_press.emit(key, index)
		%sfx.play()
		print(key)
		$sprite.modulate = Color.WHITE
		$sprite.scale = Vector2(2, 2)
	if Input.is_action_just_released(key):
		$sprite.modulate = Color8(255, 255, 255, 153)
		$sprite.scale = Vector2(1.75, 1.75)

func _process(delta):
	if !queue.is_empty():
		# Safety check: ensure the note object is still valid
		var front_note = queue.front()
		if not is_instance_valid(front_note):
			queue.pop_front()
			return

		if front_note.passed:
			print("🗑️ Removing passed note from queue for key: ", key)
			queue.pop_front()
			# print(queue.pop_front()) #

		if Input.is_action_just_pressed(key):
			var note_instance = queue.pop_front()
			# Safety check: ensure the note object is still valid
			if not is_instance_valid(note_instance):
				print("⚠️ Invalid note instance in listener: ", key)
				return

			# Check if note has already been processed
			if note_instance.processed:
				print("⚠️ Note already processed, skipping: ", key)
				note_instance.queue_free()
				return

			var distance = abs(position.y - note_instance.global_position.y)
			print("🎯 Processing hit for key: ", key, " | Distance: ", distance)

			# Mark note as processed
			note_instance.processed = true

			var rating_text = "MISS"

			if distance < distance_perfect:
				rating_text = "PERFECT"
				Manager.increment_score.emit(score_perfect)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(2.0)
				Manager.record_hit_perfect()  # Track perfect hit
			elif distance < distance_great:
				rating_text = "GREAT"
				Manager.increment_score.emit(score_great)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(1.0)
				Manager.record_hit_great()  # Track great hit
			elif distance < distance_good:
				rating_text = "GOOD"
				Manager.increment_score.emit(score_good)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(0.5)
				Manager.record_hit_good()  # Track good hit
			elif distance < distance_uninstall:
				rating_text = "UNINSTALL!"
				Manager.increment_score.emit(score_uninstall)
				Manager.reset_combo.emit()
				Manager.record_hit_uninstall()  # Track uninstall hit
			else:
				rating_text = "MISS"
				Manager.reset_combo.emit()
				Manager.decrement_spirit.emit(10.0)
				Manager.record_hit_miss()  # Track miss

			note_instance.queue_free()

			var rating_instance = rating.instantiate()
			get_tree().root.call_deferred("add_child", rating_instance)
			rating_instance.set_text(rating_text)
			rating_instance.global_position = global_position
			


func spawn_note(key_title: String):
	if key_title == key:
		var note_instance = note.instantiate()
		get_tree().root.call_deferred("add_child", note_instance)
		note_instance.setup(position.x, position.y, frame_index.get(key))

		queue.push_back(note_instance)
		print("🎵 Note spawned for key: ", key, " | Queue size: ", queue.size())


func _on_random_timeout() -> void:
	# spawn_note()
	$random.wait_time = randf_range(1, 3)
	$random.start()

# Method to clean up the queue when the game ends
func cleanup_queue():
	print("Cleaning up listener queue for key: ", key)
	queue.clear()
