# Sofa.gd (attached to RigidBody2D)
extends RigidBody2D

var player_can_interact = false

func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_can_interact = true
		body.near_interactable = self  # Reference to this object

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_can_interact = false
		body.near_interactable = null
