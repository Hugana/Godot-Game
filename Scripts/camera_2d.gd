extends Camera2D

@export var sensitivity: float = 0.05
@export var deadzone_radius: float = 100  
@export var camera_node_path: NodePath 
@export var player_path: NodePath  

@onready var viewport_center = get_viewport().size / 2
@onready var screen_size = get_viewport_rect().size

var player: Node2D 
var camera: Camera2D

const edge_offset = 50
var target_offset: Vector2 = Vector2.ZERO

enum Edge {
	NONE,
	LEFT,
	RIGHT,
	TOP,
	BOTTOM
}
const opposing_edges = {
	Edge.TOP: Edge.BOTTOM,
	Edge.BOTTOM: Edge.TOP,
	Edge.LEFT: Edge.RIGHT,
	Edge.RIGHT: Edge.LEFT
}

enum CameraMode {
	FOCUS,     # Camera follows player tightly
	GRAVITY,   # Gravity-influenced mode
	AXIAL,     # Axial inversion mode
	NORMAL,    # Default camera mode
	UNFOCUSED  # Player can move camera freely
}

var camera_mode = CameraMode.FOCUS  # Start in FOCUS mode
var mouse_edge = Edge.NONE
var result = {"is_near_edge": false, "edges": []}

func _ready() -> void:
	player = get_node(player_path)
	camera = get_node(camera_node_path)

func _process(delta: float) -> void:
	screen_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_edge = detect_mouse_edge(mouse_pos)
	var player_pos = player.position
	var player_local_pos = to_local(player.global_position)
	result = check_player_is_near_edges(player_local_pos, screen_size, edge_offset)
	
	print(camera_mode)
	# Handle Camera Mode Selection (Each mode toggles back to FOCUS when pressed again)
	if Input.is_action_just_pressed("focus_Camera"):
		if camera_mode == CameraMode.FOCUS:
			camera_mode = CameraMode.UNFOCUSED  # Toggle to unfocus mode
		else:
			camera_mode = CameraMode.FOCUS

	elif Input.is_action_just_pressed("gravity_toggle"):
		camera_mode = CameraMode.FOCUS if camera_mode == CameraMode.GRAVITY else CameraMode.GRAVITY

	elif Input.is_action_just_pressed("axial_toggle"):
		camera_mode = CameraMode.FOCUS if camera_mode == CameraMode.AXIAL else CameraMode.AXIAL

	elif Input.is_action_just_pressed("camera_1"):
		camera_mode = CameraMode.FOCUS if camera_mode == CameraMode.NORMAL else CameraMode.NORMAL

	

	# Apply Camera Behavior Based on Mode
	match camera_mode:
		CameraMode.FOCUS:
			global_position = lerp(global_position, player_pos, delta * 80)
		CameraMode.UNFOCUSED:
			move_camera_if_needed(delta)  # Allow free movement
		CameraMode.GRAVITY:
			move_camera_if_needed(delta)  # Allow free movement
		CameraMode.AXIAL:
			move_camera_if_needed(delta)  # Allow free movement
		CameraMode.NORMAL:
			global_position = lerp(global_position, player_pos, delta * 50)  # Smoother follow

func detect_mouse_edge(mouse_pos: Vector2) -> Edge:
	if mouse_pos.y <= deadzone_radius: 
		return Edge.TOP
	elif mouse_pos.x <= deadzone_radius: 
		return Edge.LEFT
	elif mouse_pos.x >= screen_size.x - deadzone_radius: 
		return Edge.RIGHT
	elif mouse_pos.y >= screen_size.y - deadzone_radius: 
		return Edge.BOTTOM
	return Edge.NONE

func move_camera_if_needed(delta: float) -> void:
	for edge in result["edges"]:
		if mouse_edge == opposing_edges.get(edge, Edge.NONE):
			return 
	
	var offset = calculate_mouse_offset(mouse_edge)
	
	if offset != Vector2.ZERO:
		global_position += offset * delta * 80

func calculate_mouse_offset(edge: Edge) -> Vector2:
	var offset = Vector2.ZERO
	if edge == Edge.TOP:
		offset.y -= sensitivity * (deadzone_radius / 2)
	elif edge == Edge.BOTTOM:
		offset.y += sensitivity * (deadzone_radius / 2)
	elif edge == Edge.LEFT:
		offset.x -= sensitivity * (deadzone_radius / 2)
	elif edge == Edge.RIGHT:
		offset.x += sensitivity * (deadzone_radius / 2)
	return offset

func check_player_is_near_edges(player_local_pos: Vector2, viewport_size: Vector2, offset: float) -> Dictionary:
	var visible_area = viewport_size / camera.zoom
	
	var edges = []
	if player_local_pos.x < -visible_area.x / 2 + offset:
		edges.append(Edge.LEFT)
	if player_local_pos.x > visible_area.x / 2 - offset:
		edges.append(Edge.RIGHT)
	if player_local_pos.y < -visible_area.y / 2 + offset:
		edges.append(Edge.TOP)
	if player_local_pos.y > visible_area.y / 2 - offset:
		edges.append(Edge.BOTTOM)

	return {"is_near_edge": edges.size() > 0, "edges": edges}
