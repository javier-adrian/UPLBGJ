extends Node2D

@export var speed: float = 2.0
@export var initial_y: float = -360

var passed: bool = false
var target: float = 0.0
var processed: bool = false  # Flag to prevent double processing


func _init():
	set_process(false)
	add_to_group("notes")  # Add to notes group for easy cleanup


func _process(_delta):
	global_position += Vector2.DOWN * speed

	if global_position.y - 40 > target and !$Timer.is_stopped() and !processed:
		# print($Timer.time_left) #
		$Timer.stop()
		passed = true
		processed = true  # Mark as processed to prevent double counting
		print("⏰ Note timed out (passed listener) - recording as miss")
		Manager.decrement_spirit.emit(10.0)
		Manager.record_hit_miss()  # Track missed note (timeout)



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func setup(x: float, y: float, frame: int):
	$sprite.frame = frame
	global_position = Vector2(x, initial_y)
	target = y
	set_process(true)

