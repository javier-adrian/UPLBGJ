extends Node2D

@onready var note = preload("res://scenes/note/note.tscn")
@export var key: String = ""

var queue = []


func _process(delta):
	if !queue.is_empty():
		if queue.front().passed:
			queue.pop_front()
			# print(queue.pop_front()) #

		if Input.is_action_just_pressed(key):
			var note = queue.pop_front()
			var distance = abs(position.y - note.global_position.y)
			note.queue_free()
			if distance < 5:
				print("perfect")
			elif distance < 10:
				print("great")
			elif distance < 20:
				print("good")
			elif distance < 40:
				print("uninstall")
			


func spawn_note():
	var note_instance = note.instantiate()
	get_tree().root.call_deferred("add_child", note_instance)
	note_instance.setup(position.x, position.y)

	queue.push_back(note_instance)


func _on_random_timeout() -> void:
	spawn_note()
	$random.wait_time = randf_range(1, 3)
	$random.start()
	
