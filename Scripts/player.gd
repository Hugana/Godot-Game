extends CharacterBody2D

var SPEED = 180.0
const SLIDE_SPEED = 350.0
const JUMP_VELOCITY = -250.0
var GRAVITY = 600
const MAX_FALL_SPEED = 800
const SLIDE_DURATION = 0.5
const PUSH_FORCE = 20

const DASH_SPEED = 700.0
const DASH_DURATION = 0.2
var is_dashing = false
var dash_timer = 0.0 
@export var camera_node_path: NodePath
@export var collision_checker_path : NodePath
@onready var RayCastRight = $RayCastRight
@onready var RayCastLeft = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var x_ray_shadder = $x_ray_shadder
@onready var screen_size = get_viewport_rect().size
@onready var raycasts = [$RayCastLeft, $RayCastRight]
@onready var collision_shape = $CollisionShape2D

var can_wrap = true
var is_xray_toggled = false
var death_bool = false
var rect
var collision_checker : CollisionShape2D
var camera: Camera2D
var is_sliding = false
var is_pulling = false
var slide_timer = 0.0
var is_movable 
var collider
var inversion = 1

enum camera_perspectives {
	NORMAL,
	INVERTED
}
var camera_perspective = camera_perspectives.NORMAL
var camera_focus_bool = true 

func _ready() -> void:
	
	
	camera = get_node(camera_node_path)
	collision_checker = get_node(collision_checker_path)
	
	rect = collision_shape.shape as RectangleShape2D
	screen_size = get_viewport().size  
	
func rayCastHandleMovables() -> Array:
	for raycast in raycasts:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			if collider and collider.is_in_group("movable"):
				var direction = Vector2(-1, 0) if raycast == $RayCastLeft else Vector2(1, 0)
				return [true, collider, direction]
	return [false, null, Vector2(0, 0)]

func _physics_process(delta: float) -> void:
	
	var player_local_pos = camera.to_local(global_position)
	var direction = Input.get_axis("move_left", "move_right")
	var result = rayCastHandleMovables()
	screen_size = get_viewport_rect().size
	
	
	set_collision_checker_pos(player_local_pos)
	
	
	
	
	is_movable = result[0]
	collider = result[1]
	
	if not is_on_floor() or not is_on_ceiling():
		velocity.y += GRAVITY * delta * inversion
		velocity.y = clamp(velocity.y, -MAX_FALL_SPEED, MAX_FALL_SPEED)

	handle_inputs(direction,delta)
	
	
	SPEED = 180
	if direction and is_movable:
		handle_movable_interaction(direction, result)

	if can_wrap:
		screen_wrap(camera_perspective == camera_perspectives.INVERTED)

	if not is_sliding and not is_dashing:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	if(!death_bool):
		move_and_slide()
		animations(direction)
		
	if is_dashing:
		handle_dash(delta)

func start_dash(direction: float) -> void:
	is_dashing = true
	dash_timer = DASH_DURATION 
	
	if direction != 0:
		velocity.x = DASH_SPEED * direction
	elif velocity.x != 0:
		velocity.x = DASH_SPEED * sign(velocity.x)
	else:
		velocity.x = DASH_SPEED * (1 if not animated_sprite.flip_h else -1)
		
func handle_movable_interaction(direction: float, result: Array) -> void:
	if is_pulling:
		SPEED = 15
		animated_sprite.play("pull")
		if result[2] == Vector2(-1, 0):  
			animated_sprite.flip_h = true
			collider.apply_impulse(Vector2(350, 0))
		elif result[2] == Vector2(1, 0):  
			animated_sprite.flip_h = false
			collider.apply_impulse(Vector2(-350, 0))
	else:
		SPEED = 75
		animated_sprite.play("push")
		if result[2] == Vector2(-1, 0):  
			animated_sprite.flip_h = false
			collider.apply_impulse(Vector2(-318, 0))
		elif result[2] == Vector2(1, 0): 
			animated_sprite.flip_h = true
			collider.apply_impulse(Vector2(318, 0))

func handle_dash(delta: float) -> void:
	dash_timer -= delta  
	if dash_timer <= 0:
		is_dashing = false 
		GRAVITY = 600
		velocity.x = 0  
		if not is_on_floor() or not is_on_ceiling():
			animated_sprite.play("jump")

func start_slide(direction: float) -> void:
	is_sliding = true
	slide_timer = SLIDE_DURATION
	adjust_collision_height(rect.size.y - 10)
	if direction != 0:
		velocity.x = SLIDE_SPEED * direction
	elif velocity.x != 0:
		velocity.x = SLIDE_SPEED * sign(velocity.x)
	else:
		velocity.x = SLIDE_SPEED
	animated_sprite.play("slide")

func handle_slide(delta: float) -> void:
	slide_timer -= delta
	if slide_timer <= 0 or (not is_on_floor() and is_on_ceiling()):
		adjust_collision_height(rect.size.y + 10)
		is_sliding = false
		velocity.x = 0
		if not is_on_floor() and is_on_ceiling():
			animated_sprite.play("jump")

func animations(direction: float) -> void:
	if (not is_on_floor() and not is_on_ceiling()) and not is_sliding and not is_dashing :
			animated_sprite.play("jump")
	elif is_sliding:
		animated_sprite.play("slide")
	elif is_dashing:
		animated_sprite.play("dash")
	else:
		if direction == 0:
			animated_sprite.play("idle")
		elif !is_movable:
			animated_sprite.play("run")

	if direction > 0 and !is_pulling:
		animated_sprite.flip_h = false
	elif direction < 0 and !is_pulling:
		animated_sprite.flip_h = true

func screen_wrap(is_inverted: bool) -> void:
	var camera_pos = camera.global_position
	var camera_zoom = camera.zoom
	var visible_width = screen_size.x / camera_zoom.x
	var visible_height = screen_size.y / camera_zoom.y

	var left_edge = camera_pos.x - visible_width / 2
	var right_edge = camera_pos.x + visible_width / 2
	var top_edge = camera_pos.y - visible_height / 2
	var bottom_edge = camera_pos.y + visible_height / 2
	
	if can_wrap:
		if is_inverted:
			var center_x = (left_edge + right_edge) / 2
			var center_y = (top_edge + bottom_edge) / 2
			if global_position.x > right_edge:
				global_position.x = left_edge
				global_position.y = center_y - (global_position.y - center_y)
			elif global_position.x < left_edge:
				global_position.x = right_edge
				global_position.y = center_y - (global_position.y - center_y)
			if global_position.y > bottom_edge:
				global_position.y = top_edge
				global_position.x = center_x - (global_position.x - center_x)
			elif global_position.y < top_edge:
				global_position.y = bottom_edge
				global_position.x = center_x - (global_position.x - center_x)
		else:
			if global_position.x > right_edge:
				global_position.x = left_edge
			elif global_position.x < left_edge:
				global_position.x = right_edge
			if global_position.y > bottom_edge:
				global_position.y = top_edge
			elif global_position.y < top_edge:
				global_position.y = bottom_edge

func adjust_collision_height(new_height: float) -> void:
	
	var height_difference = rect.size.y - new_height
	rect.size.y = new_height
	collision_shape.position.y += height_difference / 2

func _on_area_2d_body_entered(body: Node2D) -> void:
	can_wrap = false
	pass 

func _on_area_2d_body_exited(body: Node2D) -> void:
	can_wrap = true
	pass 

func handle_inputs(direction,delta):
	if Input.is_action_just_pressed("gravity_toggle"):
		inversion *= -1
		animated_sprite.scale.y = abs(animated_sprite.scale.y) * inversion
		
	if Input.is_action_just_pressed("camera_1"):
		camera_perspective = camera_perspectives.NORMAL
		
	if Input.is_action_just_pressed("camera_2"):
		camera_perspective = camera_perspectives.INVERTED
	
	if Input.is_action_just_pressed("checkpoint"):
		death_bool = false
	
	if Input.is_action_just_pressed("pull"):
		is_pulling = true
	
	if Input.is_action_just_released("pull"):
		is_pulling = false

	if Input.is_action_just_pressed("x_ray_camera_toggle"):
		toggle_xray()
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_ceiling()):
		velocity.y = JUMP_VELOCITY * inversion
		
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash(direction)
		GRAVITY = 0
		
	if Input.is_action_just_pressed("slide") and (is_on_floor() or is_on_ceiling()) and not is_sliding and (velocity.x != 0):
		start_slide(direction)
		
	if is_sliding:
		handle_slide(delta)
		
	if (Input.is_action_just_pressed("focus_Camera")):
		camera_focus_bool = !camera_focus_bool
		
func toggle_xray() -> void:
	is_xray_toggled = !is_xray_toggled
	x_ray_shadder.visible = is_xray_toggled
	
func _on_check_collision_body_entered(body: Node2D) -> void:

	if body.is_in_group("kills"):
		if(inversion == -1):
			inversion *= -1
			animated_sprite.scale.y = abs(animated_sprite.scale.y) * inversion
			
		death_bool = true
		animated_sprite.stop()
		animated_sprite.play("death")
		set_process_input(false)
		velocity = Vector2.ZERO 
		
func set_collision_checker_pos(player_local_pos) -> void:
	collision_checker.position.x = -player_local_pos.x * 2
	collision_checker.position.y = player_local_pos.y - 15
