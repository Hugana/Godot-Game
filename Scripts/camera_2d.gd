extends Camera2D

@export var sensitivity: float = 0.05
@export var bounds: Rect2 = Rect2(Vector2(0, 0), Vector2(2000, 2000))
@export var deadzone_radius: float = 100  
@export var camera_node_path: NodePath 
@export var player_path: NodePath  

@onready var viewport_center = get_viewport().size / 2
@onready var screen_size = get_viewport_rect().size

var player: Node2D 
var camera: Camera2D
var camera_focus_bool = true

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

var mouse_edge = Edge.NONE
var result = {"is_near_edge": false, "edges": []}

func _ready() -> void:
	player = get_node(player_path)
	camera = get_node(camera_node_path)

func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	mouse_edge = detect_mouse_edge(mouse_pos)

	var player_local_pos = to_local(player.global_position)
	result = check_player_is_near_edges(player_local_pos, screen_size, edge_offset)
	
	if (Input.is_action_just_pressed("focus_Camera")):
		camera_focus_bool = !camera_focus_bool
		
	if camera_focus_bool:
		global_position = lerp(global_position, player.global_position, delta * 80)
	else:
		if mouse_edge != Edge.NONE:
			move_camera_if_needed(delta)
		

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
		target_offset = clamp_vector(global_position + offset, bounds)
		global_position = lerp(global_position, target_offset, delta * 80)

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
	
	# Adjust the offset to reduce the detection area
	var detection_offset = offset * 0.5  # Change factor to make it more or less sensitive

	var edges = []
	if player_local_pos.x < -visible_area.x / 2 + detection_offset:
		edges.append(Edge.LEFT)
	if player_local_pos.x > visible_area.x / 2 - detection_offset:
		edges.append(Edge.RIGHT)
	if player_local_pos.y < -visible_area.y / 2 + detection_offset:
		edges.append(Edge.TOP)
	if player_local_pos.y > visible_area.y / 2 - detection_offset:
		edges.append(Edge.BOTTOM)

	return {"is_near_edge": edges.size() > 0, "edges": edges}


func clamp_vector(pos: Vector2, bounds: Rect2) -> Vector2:
	return Vector2(
		clamp(pos.x, bounds.position.x, bounds.position.x + bounds.size.x),
		clamp(pos.y, bounds.position.y, bounds.position.y + bounds.size.y)
	)
