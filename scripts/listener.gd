extends Node2D

@onready var note = preload("res://scenes/note/note.tscn")
@onready var rating = preload("res://scenes/rating/rating.tscn")
@export var key: String = ""
@export var index: int = 0

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
	Manager.spawn_note.connect(spawn_note)

func _input(event):
	if Input.is_action_just_pressed(key):
		Manager.listener_press.emit(key, index)

func _process(delta):
	if !queue.is_empty():
		if queue.front().passed:
			queue.pop_front()
			# print(queue.pop_front()) #

		if Input.is_action_just_pressed(key):
			var note = queue.pop_front()
			var distance = abs(position.y - note.global_position.y)

			var rating_text = "MISS"

			if distance < distance_perfect:
				rating_text = "PERFECT"
				Manager.increment_score.emit(score_perfect)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(2.0)
			elif distance < distance_great:
				rating_text = "GREAT"
				Manager.increment_score.emit(score_great)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(1.0)
			elif distance < distance_good:
				rating_text = "GOOD"
				Manager.increment_score.emit(score_good)
				Manager.increment_combo.emit()
				Manager.increment_spirit.emit(0.5)
			elif distance < distance_uninstall:
				rating_text = "UNINSTALL!"
				Manager.increment_score.emit(score_uninstall)
				Manager.reset_combo.emit()
			else:
				Manager.reset_combo.emit()
				Manager.decrement_spirit.emit(10.0)

			note.queue_free()

			var rating_instance = rating.instantiate()
			get_tree().root.call_deferred("add_child", rating_instance)
			rating_instance.set_text(rating_text)
			rating_instance.global_position = global_position
			


func spawn_note(key_title: String):
	if key_title == key:
		var note_instance = note.instantiate()
		get_tree().root.call_deferred("add_child", note_instance)
		note_instance.setup(position.x, position.y)

		queue.push_back(note_instance)


func _on_random_timeout() -> void:
	# spawn_note()
	$random.wait_time = randf_range(1, 3)
	$random.start()
	
