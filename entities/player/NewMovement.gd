extends CharacterBody2D

var speed = 300  # move speed in pixels/sec
var rotation_speed = 0.8  # turning speed in radians/sec

func _physics_process(delta):
	var move_input = Input.get_axis("move_down", "move_up")
	var rotation_direction = Input.get_axis("move_left", "move_right")
	velocity = transform.x * move_input * speed
	rotation += rotation_direction * rotation_speed * delta
	move_and_slide()
