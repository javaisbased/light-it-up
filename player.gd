extends CharacterBody2D # Or Sprite2D if no physics needed for player itself

# Signal to notify the world to translate
signal translate_world(amount) # Amount of translation (positive for forward, negative for backward)
# Signal to notify the world to rotate
signal rotate_world(angle_rad)  # Angle in radians to rotate the world

# Player's movement speed - this will effectively be the world's movement speed
@export var speed = 200.0
@export var turn_speed_deg_sec = 90.0 # Degrees per second for world rotation

# This variable will track the player's current interaction layer capability
# 0 = Base, 1 = Candle, 2 = Stepladder (future)
var current_interaction_layer = 0
var has_candle = false

func _physics_process(delta):
	var forward_input = 0.0
	var rotation_input = 0.0

	if Input.is_action_pressed("move_up"): # Forward
		forward_input += 1.0
	if Input.is_action_pressed("move_down"): # Backward
		forward_input -= 1.0

	if Input.is_action_pressed("move_right"): # Turn Right
		rotation_input += 1.0
	if Input.is_action_pressed("move_left"): # Turn Left
		rotation_input -= 1.0

	# Handle translation (forward/backward)
	if forward_input != 0.0:
		emit_signal("translate_world", forward_input * speed * delta)

	# Handle rotation (turning left/right)
	if rotation_input != 0.0:
		emit_signal("rotate_world", rotation_input * deg_to_rad(turn_speed_deg_sec) * delta)

func _input(event):
	if event.is_action_pressed("interact"):
		print("Interact action pressed")
		# Interaction logic will go here later
		# For example, check for nearby interactable objects

# Call this function when the player picks up the candle
func pickup_candle():
	has_candle = true
	current_interaction_layer = 1
	print("Candle picked up! Interaction layer set to 1.")
	# Logic to enable light aura will go here

# Placeholder for stepladder
func pickup_stepladder():
	current_interaction_layer = 2
	print("Stepladder picked up! Interaction layer set to 2.")
