extends StaticBody2D

@export var interaction_radius_factor: float = 0.75
@export var visibility_close_radius_factor: float = 1.5
@export var visibility_far_radius_factor: float = 3.0

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
    _adjust_collision_shapes()
    sprite.visible = false # Start hidden

    interaction_area.body_entered.connect(_on_interaction_area_body_entered)

    visibility_area_close.body_entered.connect(_on_visibility_area_close_body_entered)
    visibility_area_close.body_exited.connect(_on_visibility_area_close_body_exited)

    visibility_area_far.body_entered.connect(_on_visibility_area_far_body_entered)
    visibility_area_far.body_exited.connect(_on_visibility_area_far_body_exited)

func _adjust_collision_shapes():
    if not sprite.texture:
        push_warning(self.name + ": Sprite2D has no texture assigned. Cannot adjust collision shapes.")
        return

    var texture_size: Vector2 = sprite.texture.get_size()

    # Adjust Physics Collision Shape (RectangleShape2D)
    if physics_shape_node and physics_shape_node.shape is RectangleShape2D:
        physics_shape_node.shape.size = texture_size
    else:
        push_warning(self.name + ": Physics_shape_node is not a CollisionShape2D with a RectangleShape2D.")

    # Calculate a base dimension for relative sizing of other areas
    # Ensure sprite scale is considered if the sprite itself is scaled in the editor.
    var effective_texture_size = texture_size # * sprite.scale # Uncomment if sprite might be scaled
    var base_dimension = (effective_texture_size.x + effective_texture_size.y) / 2.0
    
    if base_dimension <= 0: # Avoid division by zero or negative radius if texture size is invalid
        push_warning(self.name + ": Texture size is invalid for calculating relative collision shapes.")
        return

    # Adjust Interaction Area Shape (CircleShape2D)
    if interaction_shape_node and interaction_shape_node.shape is CircleShape2D:
        interaction_shape_node.shape.radius = base_dimension * interaction_radius_factor
    else:
        push_warning(self.name + ": Interaction_shape_node is not a CollisionShape2D with a CircleShape2D.")

    # Adjust Visibility Close Area Shape (CircleShape2D)
    if visibility_close_shape_node and visibility_close_shape_node.shape is CircleShape2D:
        visibility_close_shape_node.shape.radius = base_dimension * visibility_close_radius_factor
    else:
        push_warning(self.name + ": Visibility_close_shape_node is not a CollisionShape2D with a CircleShape2D.")

    # Adjust Visibility Far Area Shape (CircleShape2D)
    if visibility_far_shape_node and visibility_far_shape_node.shape is CircleShape2D:
        visibility_far_shape_node.shape.radius = base_dimension * visibility_far_radius_factor
    else:
        push_warning(self.name + ": Visibility_far_shape_node is not a CollisionShape2D with a CircleShape2D.")


func _on_interaction_area_body_entered(body):
    if body.is_in_group("player"):
        # print("Player entered interaction area of: ", name) # Example interaction
        # You can add specific interaction logic here, perhaps by emitting a signal
        # or calling a method on the player if an interaction button is pressed.
        pass

func _on_visibility_area_close_body_entered(body):
    if body.is_in_group("player"):
        player_in_close_area = true
        current_player_ref = body
        _update_visibility()

func _on_visibility_area_close_body_exited(body):
    if body.is_in_group("player"):
        player_in_close_area = false
        if not player_in_far_area: # Only nullify if also outside far area
            current_player_ref = null
        _update_visibility()

func _on_visibility_area_far_body_entered(body):
    if body.is_in_group("player"):
        player_in_far_area = true
        current_player_ref = body # Player is at least in the far area
        _update_visibility()

func _on_visibility_area_far_body_exited(body):
    if body.is_in_group("player"):
        player_in_far_area = false
        if not player_in_close_area: # Only nullify if also outside close area
            current_player_ref = null 
        _update_visibility()

func _update_visibility():
    if not current_player_ref:
        sprite.visible = false
        return

    # Ensure current_player_ref has LightLevel. 
    # If not, you might need to handle it, e.g., assume a default or log an error.
    if not current_player_ref.has_method("get_light_level") and not 'LightLevel' in current_player_ref:
        push_warning(self.name + ": Player node does not have 'LightLevel' property or 'get_light_level' method.")
        sprite.visible = false # Or some default visibility
        return
        
    var player_light_level: int
    if current_player_ref.has_method("get_light_level"):
        player_light_level = current_player_ref.get_light_level()
    else:
        player_light_level = current_player_ref.LightLevel

    # Visibility logic: If LightLevel is 0, only visible in close area.
    # If LightLevel >= 1, visible in either far or close area.
    if player_light_level == 0:
        sprite.visible = player_in_close_area
    else: # LightLevel >= 1
        sprite.visible = player_in_far_area or player_in_close_area
