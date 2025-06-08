extends Node2D

@export var speed: float = 2.0
@export var initial_y: float = -360

var passed: bool = false
var target: float = 0.0


func _init():
	set_process(false)
	add_to_group("notes")  # Add to notes group for easy cleanup


func _process(delta):
	global_position += Vector2.DOWN * speed

	if global_position.y - 40 > target and !$Timer.is_stopped():
		# print($Timer.time_left) #
		$Timer.stop()
		passed = true
		Manager.decrement_spirit.emit(10.0)



func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func setup(x: float, y: float, frame: int):
	$sprite.frame = frame
	global_position = Vector2(x, initial_y)
	target = y
	set_process(true)

