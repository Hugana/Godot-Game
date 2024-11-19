extends CharacterBody2D


const SPEED = 180.0
const SLIDE_SPEED = 350.0
const JUMP_VELOCITY = -250.0 
const GRAVITY = 600
const MAX_FALL_SPEED = 800
const SLIDE_DURATION = 0.5

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
	

	
	if Input.is_action_just_pressed("slide") and is_on_floor() and not is_sliding and (velocity.x > 0 or velocity.x < 0):
		print("a slidar")
		start_slide(direction)
	elif is_sliding:
		handle_slide(delta)
		
	if Input.is_action_just_pressed("camera_1"):
		camera_perspective = camera_perspectives.NORMAL
	if Input.is_action_just_pressed("camera_2"):
		camera_perspective = camera_perspectives.INVERTED
	
	if camera_perspective == camera_perspectives.NORMAL:
		screen_wrap_normal()

	
	if not is_sliding:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	
	animations(direction)

	move_and_slide()
	

func start_slide(direction: float) -> void:
	is_sliding = true
	slide_timer = SLIDE_DURATION


	if direction != 0: 
	
		velocity.x = SLIDE_SPEED * direction
	elif velocity.x != 0: 

		velocity.x = SLIDE_SPEED * sign(velocity.x)
	else:

		velocity.x = SLIDE_SPEED

	animated_sprite.play("slide")

func handle_slide(delta: float) -> void:
	slide_timer -= delta
	if slide_timer <= 0 or not is_on_floor():
		is_sliding = false
		velocity.x = 0
		if not is_on_floor():
			animated_sprite.play("jump")

func animations(direction: float) -> void:
	if not is_on_floor() and not is_sliding:
		if velocity.y < 0:
			animated_sprite.play("jump")
	elif is_sliding:
		animated_sprite.play("slide")
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
		#print("Reached the right edge!")
		global_position.x = left_edge
	elif global_position.x < left_edge:
		#print("Reached the left edge!")
		global_position.x = right_edge

	if global_position.y > bottom_edge:
		#print("Reached the bottom edge!")
		global_position.y = top_edge
	elif global_position.y < top_edge:
		#print("Reached the top edge!")
		global_position.y = bottom_edge
		
