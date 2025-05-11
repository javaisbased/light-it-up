extends CharacterBody2D

var speed = 320  # move speed in pixels/sec
var rotation_speed = 0.8  # turning speed in radians/sec
var rotation_speed_multiplier = 1


func _physics_process(_delta):
	pass #_physics_process should only be used for physics processes, not movement

func _process(delta):
	if Input.is_action_pressed("move_left"):
		if rotation_speed_multiplier < 1.6:
				rotation_speed_multiplier += delta * 1.2
	if Input.is_action_just_released("move_left"):
		rotation_speed_multiplier = 1
	if Input.is_action_pressed("move_right"):
		if rotation_speed_multiplier < 1.6:
			rotation_speed_multiplier += delta * 1.2
	if Input.is_action_just_released("move_right"):
		rotation_speed_multiplier = 1
	if Input.is_action_pressed("move_up"):
		if speed <= 500:
			speed += delta * 50
	if Input.is_action_just_released("move_up"):
		speed = 300
	var move_input = Input.get_axis("move_down", "move_up")
	var rotation_direction = Input.get_axis("move_left", "move_right")
	velocity = transform.x * move_input * speed
	rotation += rotation_direction * rotation_speed * delta * rotation_speed_multiplier
	move_and_slide()
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_up"):
		$AnimatedSprite2D.play("walk-left")
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_up"):
		$AnimatedSprite2D.play("walk-right")
	if Input.is_action_pressed("move_up"):
		$AnimatedSprite2D.play("walk-up")
	if not Input.is_anything_pressed():
		$AnimatedSprite2D.play("idle-down")
