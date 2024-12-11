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

@export var collision_checker_path : NodePath

@onready var RayCastRight = $RayCastRight
@onready var RayCastLeft = $RayCastLeft


@onready var animated_sprite = $AnimatedSprite2D
@onready var x_ray_shadder = $x_ray_shadder
@onready var screen_size = get_viewport_rect().size

@onready var collision_shape = $CollisionShape2D

var can_wrap = true
var is_xray_toggled = false

var death_bool = false

var rect

@export var camera_node_path: NodePath
var collision_checker : CollisionShape2D
var camera: Camera2D

var is_sliding = false
var is_pulling = false
var slide_timer = 0.0

var is_movable 
var collider

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
	# Check if RayCastLeft is colliding
	if $RayCastLeft.is_colliding():
		var collider = $RayCastLeft.get_collider()
		if collider and collider.is_in_group("movable"):	
			return [true, collider, Vector2(-1, 0)]  # Direction is left
	
	# Check if RayCastRight is colliding
	if $RayCastRight.is_colliding():
		var collider = $RayCastRight.get_collider()
		if collider and collider.is_in_group("movable"):
		
			return [true, collider, Vector2(1, 0)]  # Direction is right
	return [false, null, Vector2(0, 0)]  # No collision


func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("checkpoint"):
		death_bool = false
	
	var result = rayCastHandleMovables()
	is_movable = result[0]
	collider = result[1]
	
	
	
	screen_size = get_viewport_rect().size
	var player_local_pos = camera.to_local(global_position)
	var direction = Input.get_axis("move_left", "move_right")
	
	collision_checker.position.x = -player_local_pos.x * 2
	collision_checker.position.y = player_local_pos.y - 15

	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	handle_inputs(direction,delta)
	
	if Input.is_action_just_pressed("pull"):
		is_pulling = true
		
		
	if Input.is_action_just_released("pull"):
		is_pulling = false
	
	
	
	
	
	if direction and is_movable:
		if is_pulling:
			SPEED = 15
			if is_movable and result[2] == Vector2(-1, 0):
				animated_sprite.flip_h = true
				animated_sprite.play("pull")
				collider.apply_impulse(Vector2(350, 0)) 
			elif is_movable and result[2] == Vector2(1, 0):
				animated_sprite.flip_h = false
				animated_sprite.play("pull")
				collider.apply_impulse(Vector2(-350, 0)) 
		else:
			SPEED = 80
			if is_movable and result[2] == Vector2(-1, 0):
				animated_sprite.flip_h = false
				animated_sprite.play("push")
				collider.apply_impulse(Vector2(-320, 0)) 
			elif is_movable and result[2] == Vector2(1, 0):
				animated_sprite.flip_h = true
				animated_sprite.play("push")
				collider.apply_impulse(Vector2(320, 0)) 
				
	SPEED = 180
	
	#push_elements()
	
	if can_wrap:
		if camera_perspective == camera_perspectives.NORMAL:
			screen_wrap_normal()
		elif camera_perspective == camera_perspectives.INVERTED:
			screen_wrap_inverted()

	if not is_sliding and not is_dashing:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	if(!death_bool):
		animations(direction)
		move_and_slide()

	
	if is_dashing:
		handle_dash(delta)

func start_dash(direction: float) -> void:
	is_dashing = true
	dash_timer = DASH_DURATION 

	# Dash based on direction
	if direction != 0:
		velocity.x = DASH_SPEED * direction
	elif velocity.x != 0:
		velocity.x = DASH_SPEED * sign(velocity.x)
	else:
		velocity.x = DASH_SPEED * (1 if not animated_sprite.flip_h else -1)


func handle_dash(delta: float) -> void:
	dash_timer -= delta  
	if dash_timer <= 0:
		is_dashing = false 
		GRAVITY = 600
		velocity.x = 0  
		if not is_on_floor():
			animated_sprite.play("jump")

func start_slide(direction: float) -> void:
	is_sliding = true
	slide_timer = SLIDE_DURATION
	
	adjust_collision_height(rect.size.y - 10)
	
	# Slide based on direction
	if direction != 0:
		velocity.x = SLIDE_SPEED * direction
	elif velocity.x != 0:
		velocity.x = SLIDE_SPEED * sign(velocity.x)
	else:
		velocity.x = SLIDE_SPEED

	# Play slide animation
	animated_sprite.play("slide")

func handle_slide(delta: float) -> void:
	slide_timer -= delta
	if slide_timer <= 0 or not is_on_floor():
		
		
		adjust_collision_height(rect.size.y + 10)
		
		is_sliding = false
		velocity.x = 0
		if not is_on_floor():
			animated_sprite.play("jump")

func animations(direction: float) -> void:
	if not is_on_floor() and not is_sliding and not is_dashing:
		if velocity.y < 0:
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
		


	
	if Input.is_action_just_pressed("camera_1"):
		camera_perspective = camera_perspectives.NORMAL
	if Input.is_action_just_pressed("camera_2"):
		camera_perspective = camera_perspectives.INVERTED
		
func screen_wrap_inverted():
	var camera_pos = camera.global_position
	var camera_zoom = camera.zoom  
	var visible_width = screen_size.x / camera_zoom.x
	var visible_height = screen_size.y / camera_zoom.y

	var left_edge = camera_pos.x - visible_width / 2 
	var right_edge = camera_pos.x + visible_width / 2
	var top_edge = camera_pos.y - visible_height / 2
	var bottom_edge = camera_pos.y + visible_height / 2


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


func screen_wrap_normal():
	var camera_pos = camera.global_position
	var camera_zoom = camera.zoom  
	var visible_width = screen_size.x / camera_zoom.x
	var visible_height = screen_size.y / camera_zoom.y

	var left_edge = camera_pos.x - visible_width / 2 
	var right_edge = camera_pos.x + visible_width / 2
	var top_edge = camera_pos.y - visible_height / 2
	var bottom_edge = camera_pos.y + visible_height / 2
	
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
	
	
		
	if Input.is_action_just_pressed("x_ray_camera_toggle"):
		is_xray_toggled = !is_xray_toggled
		x_ray_shadder.visible = is_xray_toggled
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash(direction)
		GRAVITY = 0

	
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and (velocity.x != 0):
		start_slide(direction)
	
	if is_sliding:
		handle_slide(delta)
		
	if (Input.is_action_just_pressed("focus_Camera")):
		camera_focus_bool = !camera_focus_bool
	
func push_elements():
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)


func _on_check_collision_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("kills"):
		# Stop all current animations
		death_bool = true
		animated_sprite.stop()
		print("kills");
		
		# Play the death animation (ensure "death" exists in your AnimatedSprite2D)
		animated_sprite.play("death")
		
		# Disable player input
		set_process_input(false)
		velocity = Vector2.ZERO 
