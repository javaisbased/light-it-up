extends CharacterBody2D

var speed = 300  # move speed in pixels/sec
var rotation_speed = 0.8  # turning speed in radians/sec
var rotation_speed_multiplier = 1

	


func _physics_process(delta):
	var move_input = Input.get_axis("move_down", "move_up")
	var rotation_direction = Input.get_axis("move_left", "move_right")
	velocity = transform.x * move_input * speed
	rotation += rotation_direction * rotation_speed * delta * rotation_speed_multiplier
	
	move_and_slide()

func _process(delta):
	if Input.is_action_pressed("move_left"):
		if rotation_speed_multiplier < 2:
				rotation_speed_multiplier += delta
	if Input.is_action_just_released("move_left"):
		rotation_speed_multiplier = 1
	if Input.is_action_pressed("move_right"):
		if rotation_speed_multiplier < 2:
			rotation_speed_multiplier += delta
	if Input.is_action_just_released("move_right"):
		rotation_speed_multiplier = 1
