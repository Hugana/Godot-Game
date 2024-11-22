extends StaticBody2D

@onready var collider = $CollisionShape2D
@onready var sprite2D = $Sprite2D
@export var distance_top_bottom_edge: float = 50
@export var distance_right_left_edge: float = 50

@export var camera_path: NodePath  # Path to the Camera2D node
var camera: Camera2D

func _ready() -> void:
	camera = get_node(camera_path)

func _process(delta: float) -> void:
	# Get the camera's global position, zoom, and viewport size
	var camera_position = camera.global_position
	var camera_zoom = camera.zoom
	var viewport_size = get_viewport_rect().size / camera_zoom

	# Calculate the camera's visible edges
	var left_edge = camera_position.x - viewport_size.x / 2
	var right_edge = camera_position.x + viewport_size.x / 2
	var top_edge = camera_position.y - viewport_size.y / 2
	var bottom_edge = camera_position.y + viewport_size.y / 2

	# Get the collider's global position
	var collider_position = global_position

	# Calculate distances from the collider to the screen edges
	var distance_to_left = collider_position.x - left_edge
	var distance_to_right = right_edge - collider_position.x
	var distance_to_top = collider_position.y - top_edge
	var distance_to_bottom = bottom_edge - collider_position.y

	# Check if the collider is within the specified distances
	var should_disable_collider = (
		distance_to_left < distance_right_left_edge or
		distance_to_right < distance_right_left_edge or
		distance_to_top < distance_top_bottom_edge or
		distance_to_bottom < distance_top_bottom_edge
	)

	# Enable or disable the collider
	collider.disabled = should_disable_collider
	
	# Adjust the opacity of the sprite
	if should_disable_collider:
		sprite2D.modulate = Color(1, 1, 1, 0.5)  # 50% opacity
	else:
		sprite2D.modulate = Color(1, 1, 1, 1)  # Fully visible
