extends Node2D

# This function will be called by the player script via the 'translate_world' signal
func _on_player_translate_world(amount):
	# 'amount' is positive for player "forward" (world moves along its positive Y / "down" on screen if unrotated)
	# and negative for player "backward" (world moves along its negative Y / "up" on screen if unrotated)
	# We move the world along its own local Y-axis.
	# The player is conceptually fixed, facing "up" (-Y in screen space).
	# So, to make the player appear to move forward (up), the world moves in its 'transform.y' direction.
	self.position += self.transform.y.normalized() * amount

# This function will be called by the player script via the 'rotate_world' signal
func _on_player_rotate_world(angle_rad):
	# The pivot point for rotation is the player's fixed position, which we assume
	# is (0,0) in the global coordinate system of the Main scene.
	var pivot_point_global = Vector2.ZERO

	# Get the current global position of this World node.
	# If World is a direct child of Main (which is at 0,0), then global_position = position.
	var current_world_global_pos = self.global_position

	# Calculate the vector from the pivot to the world's current origin.
	var offset_from_pivot = current_world_global_pos - pivot_point_global

	# Rotate this offset vector. This tells us where the World's origin should *move to*
	# so that its content appears to have rotated around the pivot_point_global.
	var rotated_offset = offset_from_pivot.rotated(angle_rad)

	# The new global position for the World node is the pivot plus the rotated offset.
	self.global_position = pivot_point_global + rotated_offset

	# Now, also apply the rotation to the World node itself so its contents are oriented correctly.
	self.rotation += angle_rad
