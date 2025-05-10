extends Node2D

# This function will be called by the player script via the 'translate_world' signal
# 'direction' is the player's forward vector (e.g., player.transform.y, which is already normalized)
# 'amount' is the signed magnitude of player's movement (positive for player "forward", negative for player "backward")
func _on_player_translate_world(direction, amount):
	# The player intends to move by the vector (direction * amount).
	# To achieve this with a fixed player, the world must move by the inverse vector.
	self.position -= direction * amount


func _on_audio_stream_player_2d_finished() -> void:
	pass # Replace with function body.
