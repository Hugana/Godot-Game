extends StaticBody2D

@onready var collider = $CollisionShape2D
@onready var sprite2D = $Sprite2D
@export var distance_top_bottom_edge: float = 50
@export var distance_right_left_edge: float = 50
@export var camera_path: NodePath  # Path to the Camera2D node

var camera: Camera2D
var player_on_top: bool = false

# Reference to the player character (assumed to be a CharacterBody2D)
@export var player: NodePath
var player_body: CharacterBody2D

func _ready() -> void:
	# Get the player reference
	player_body = get_node(player) as CharacterBody2D
	camera = get_node(camera_path)

func _process(delta: float) -> void:
	# Check if the player is colliding with the platform
	if player_body.is_on_floor() and player_body.get_floor_normal().y > 0.1:
		player_on_top = true
	else:
		player_on_top = false


	var camera_position = camera.global_position
	var camera_zoom = camera.zoom
	var viewport_size = get_viewport_rect().size / camera_zoom

	var left_edge = camera_position.x - viewport_size.x / 2
	var right_edge = camera_position.x + viewport_size.x / 2
	var top_edge = camera_position.y - viewport_size.y / 2
	var bottom_edge = camera_position.y + viewport_size.y / 2

	var collider_position = global_position

	var distance_to_left = collider_position.x - left_edge
	var distance_to_right = right_edge - collider_position.x
	var distance_to_top = collider_position.y - top_edge
	var distance_to_bottom = bottom_edge - collider_position.y

	# Check if near the edge
	var near_edge = (
		distance_to_left < distance_right_left_edge or
		distance_to_right < distance_right_left_edge or
		distance_to_top < distance_top_bottom_edge or
		distance_to_bottom < distance_top_bottom_edge
	)

	# Determine whether to disable the collider based on player position and edge proximity
	var should_disable_collider = false
	
	if player_on_top:
		should_disable_collider = false
		#print("Estou em cima da plataforma")
	else:
		if near_edge:
			should_disable_collider = true
			#print("Não estou em cima da plataforma e na borda")
		else:
			should_disable_collider = false
			#print("Não estou em cima da plataforma nem na borda")

	# Apply the logic to disable or enable the collider and adjust opacity
	collider.disabled = should_disable_collider

	if should_disable_collider:
		sprite2D.modulate = Color(1, 1, 1, 0.5)
	else:
		sprite2D.modulate = Color(1, 1, 1, 1)
