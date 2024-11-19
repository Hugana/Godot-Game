extends CharacterBody2D

const SPEED = 180.0
const SLIDE_SPEED = 350.0
const JUMP_VELOCITY = -250.0
var GRAVITY = 600
const MAX_FALL_SPEED = 800
const SLIDE_DURATION = 0.5

const DASH_SPEED = 700.0
const DASH_DURATION = 0.2
var is_dashing = false
var dash_timer = 0.0 

@onready var animated_sprite = $AnimatedSprite2D
@onready var screen_size = get_viewport_rect().size

@export var camera_node_path: NodePath
var camera: Camera2D

var is_sliding = false
var slide_timer = 0.0

enum camera_perspectives {
	NORMAL,
	INVERTED
}

var camera_perspective = camera_perspectives.NORMAL

func _ready() -> void:
	camera = get_node(camera_node_path)
	screen_size = get_viewport().size  

func _physics_process(delta: float) -> void:
	screen_size = get_viewport_rect().size

	var direction = Input.get_axis("move_left", "move_right")

	if not is_on_floor():
		velocity.y = min(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash(direction)
		GRAVITY = 0

	
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and (velocity.x != 0):
		start_slide(direction)
	
	if is_sliding:
		handle_slide(delta)

	# Camera perspective handling
	if Input.is_action_just_pressed("camera_1"):
		camera_perspective = camera_perspectives.NORMAL
	if Input.is_action_just_pressed("camera_2"):
		camera_perspective = camera_perspectives.INVERTED
	
	if camera_perspective == camera_perspectives.NORMAL:
		screen_wrap_normal()

	
	if not is_sliding and not is_dashing:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

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
		else:
			animated_sprite.play("run")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

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
