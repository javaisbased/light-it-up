@tool
extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var physics_shape_node: CollisionShape2D = $CollisionShape2D_Physics

@onready var interaction_area: Area2D = $InteractionArea
@onready var interaction_shape_node: CollisionShape2D = $InteractionArea/CollisionShape2D_Interaction

@onready var visibility_area_close: Area2D = $VisibilityAreaClose
@onready var visibility_close_shape_node: CollisionShape2D = $VisibilityAreaClose/CollisionShape2D_VisibilityClose

@onready var visibility_area_far: Area2D = $VisibilityAreaFar
@onready var visibility_far_shape_node: CollisionShape2D = $VisibilityAreaFar/CollisionShape2D_VisibilityFar

var player_in_close_area: bool = false
var player_in_far_area: bool = false
var current_player_ref # To store the player node when it's in an area

func _ready():
	if not Engine.is_editor_hint():
		# Runtime logic
		sprite.visible = false # Start hidden
		
		# Check if already connected to prevent duplicate connections
		if not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
			interaction_area.body_entered.connect(_on_interaction_area_body_entered)

		if not visibility_area_close.body_entered.is_connected(_on_visibility_area_close_body_entered):
			visibility_area_close.body_entered.connect(_on_visibility_area_close_body_entered)
		if not visibility_area_close.body_exited.is_connected(_on_visibility_area_close_body_exited):
			visibility_area_close.body_exited.connect(_on_visibility_area_close_body_exited)

		if not visibility_area_far.body_entered.is_connected(_on_visibility_area_far_body_entered):
			visibility_area_far.body_entered.connect(_on_visibility_area_far_body_entered)
		if not visibility_area_far.body_exited.is_connected(_on_visibility_area_far_body_exited):
			visibility_area_far.body_exited.connect(_on_visibility_area_far_body_exited)
		
		_adjust_collision_shapes() # Adjust shapes at runtime too
	else:
		# Editor-time logic: Defer setup to ensure scene is fully loaded
		call_deferred("_editor_setup")

func _editor_setup():
	if not is_inside_tree(): # Node might have been removed
		return

	if not sprite:
		push_error("BedPattern1a (Editor): Sprite2D node not found. Cannot perform editor setup.")
		return
		
	if not sprite.texture:
		push_error("BedPattern1a (Editor): Sprite2D has no texture assigned. Cannot adjust shapes in editor. Ensure texture is set on Sprite2D node.")
		# Attempt to make sprite visible anyway if it exists, so user can see it
		sprite.visible = true 
		return

	_adjust_collision_shapes()
	_update_visibility() # Ensures sprite is visible in editor and other editor-specific visibility logic

	# Try to force editor updates
	if physics_shape_node: physics_shape_node.update_configuration_warnings()
	if interaction_shape_node: interaction_shape_node.update_configuration_warnings()
	if visibility_close_shape_node: visibility_close_shape_node.update_configuration_warnings()
	if visibility_far_shape_node: visibility_far_shape_node.update_configuration_warnings()
	
	notify_property_list_changed() # Use the correct method name

func _adjust_collision_shapes():
	if not sprite: 
		push_warning("BedPattern1a: Sprite node not found in _adjust_collision_shapes.")
		return

	if not sprite.texture:
		# This check is crucial, especially if called directly or if _editor_setup's check passed but something changed
		if Engine.is_editor_hint():
			push_error("BedPattern1a (Editor): Sprite2D texture is NULL in _adjust_collision_shapes. Aborting adjustment.")
		else:
			push_warning("BedPattern1a: Sprite2D has no texture assigned at runtime. Cannot adjust collision shapes.")
		return

	var texture_size: Vector2 = sprite.texture.get_size()

	if physics_shape_node: 
		var new_physics_shape = RectangleShape2D.new()
		new_physics_shape.size = texture_size
		physics_shape_node.shape = new_physics_shape
	else: 
		push_warning("BedPattern1a: Physics_shape_node not found.")

	var effective_texture_size = texture_size 
	var base_dimension = (effective_texture_size.x + effective_texture_size.y) / 2.0
	
	if base_dimension <= 0: 
		if not Engine.is_editor_hint(): # Don't spam warnings in editor for transient states
			push_warning("BedPattern1a: Texture size is invalid for calculating relative collision shapes.")
		elif Engine.is_editor_hint() and base_dimension <= 0: # Specific editor warning for this case if texture was valid
			 push_warning("BedPattern1a (Editor): Calculated base_dimension is <=0. Check texture dimensions.")
		return

	if interaction_shape_node: 
		var new_interaction_shape = CircleShape2D.new()
		new_interaction_shape.radius = base_dimension * 0.75
		interaction_shape_node.shape = new_interaction_shape
	else:
		push_warning("BedPattern1a: Interaction_shape_node not found.")

	if visibility_close_shape_node: 
		var new_visibility_close_shape = CircleShape2D.new()
		new_visibility_close_shape.radius = base_dimension * 1.5
		visibility_close_shape_node.shape = new_visibility_close_shape
	else:
		push_warning("BedPattern1a: Visibility_close_shape_node not found.")

	if visibility_far_shape_node: 
		var new_visibility_far_shape = CircleShape2D.new()
		new_visibility_far_shape.radius = base_dimension * 3.0
		visibility_far_shape_node.shape = new_visibility_far_shape
	else:
		push_warning("BedPattern1a: Visibility_far_shape_node not found.")
	
	# update_configuration_warnings and property_list_changed_notify are now in _editor_setup for editor path
	# For runtime, these are not typically needed unless debugging specific issues.

func _on_interaction_area_body_entered(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		pass

func _on_visibility_area_close_body_entered(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		player_in_close_area = true
		current_player_ref = body
		_update_visibility()

func _on_visibility_area_close_body_exited(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		player_in_close_area = false
		if not player_in_far_area: 
			current_player_ref = null
		_update_visibility()

func _on_visibility_area_far_body_entered(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		player_in_far_area = true
		current_player_ref = body 
		_update_visibility()

func _on_visibility_area_far_body_exited(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player"):
		player_in_far_area = false
		if not player_in_close_area: 
			current_player_ref = null 
		_update_visibility()

func _update_visibility():
	if Engine.is_editor_hint(): 
		# In editor, make sprite visible so we can see it, regardless of player
		if sprite: sprite.visible = true 
		return
		
	if not current_player_ref:
		sprite.visible = false
		return

	if not current_player_ref.has_method("get_light_level") and not 'LightLevel' in current_player_ref:
		push_warning("BedPattern1a: Player node does not have 'LightLevel' property or 'get_light_level' method.")
		sprite.visible = false 
		return
		
	var player_light_level: int
	if current_player_ref.has_method("get_light_level"):
		player_light_level = current_player_ref.get_light_level()
	else:
		player_light_level = current_player_ref.LightLevel

	if player_light_level == 0:
		sprite.visible = player_in_close_area
	else: 
		sprite.visible = player_in_far_area or player_in_close_area
