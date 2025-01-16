extends CharacterBody2D

# Movement variables
var SPEED = 180.0
const SLIDE_SPEED = 350.0
const JUMP_VELOCITY = -250.0
var GRAVITY = 600
const MAX_FALL_SPEED = 600
const SLIDE_DURATION = 0.5
const PUSH_FORCE = 20
const DASH_SPEED = 700.0
const DASH_DURATION = 0.2
var is_dashing = false
var dash_timer = 0.0 
var mirrored_pos
var was_in_air = false

var step_timer = 0.0  
const STEP_INTERVAL = 0.3


const DASH_COOLDOWN = 1.5
var rng = RandomNumberGenerator.new()



@export var is_dash_on_cooldown = false  
@export var dash_cooldown_timer = Timer.new()

@export var camera_node_path: NodePath
@export var collision_checker_path : NodePath
@export var  audio_player_node: NodePath
@onready var  audio_player = $AudioStreamPlayer
@onready var RayCastRight = $RayCastRight
@onready var RayCastLeft = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var x_ray_shadder = $x_ray_shadder
@onready var screen_size = get_viewport_rect().size
@onready var raycasts = [$RayCastLeft, $RayCastRight]
@onready var collision_shape = $CollisionShape2D

var gravity_toggle = false
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

var sound_dict = {
	"jump": preload("res://Assets/sounds/Jump sound effect.mp3"),
	"landing": preload("res://Assets/sounds/Landing Effect.mp3"),
	"step": preload("res://Assets/sounds/footsteps-sound-effect.mp3"),
	"dash": preload("res://Assets/sounds/Dash Sound Effect.mp3")
}

# X-ray battery values
@export var max_battery = 60.0 # Maximum battery life in seconds
var current_battery = max_battery
var xray_active = false

# X-ray timer node
@onready var xray_timer = Timer.new()
@onready var battery: TextureProgressBar = $"../UI/Battery"

# X-ray signal
signal xray_toggled(xray_active)  # Emit this signal when toggling X-ray

enum camera_perspectives {
	NORMAL,
	INVERTED,
	GRAVITY
}

var camera_perspective = camera_perspectives.NORMAL
var camera_focus_bool = true 

func _ready() -> void:
	
	# Dash timer
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.wait_time = DASH_COOLDOWN
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.connect("timeout", Callable(self, "_on_dash_cooldown_timeout"))
	
	# X-ray timer
	add_child(xray_timer)
	xray_timer.one_shot = false
	xray_timer.wait_time = 1.0 # Reduce battery every second
	xray_timer.connect("timeout", Callable(self, "_on_xray_timer_timeout"))

	# Initialize the progress bar
	battery.value = current_battery
	battery.max_value = max_battery
	
	audio_player = get_node(audio_player_node)
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
	
	# Set camera pos
	var player_local_pos = camera.to_local(global_position)
	
	# Set collision checker pos
	set_collision_checker_pos(player_local_pos)
	
	var direction = Input.get_axis("move_left", "move_right")
	var result = rayCastHandleMovables()
	screen_size = get_viewport_rect().size
	
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
		screen_wrap(camera_perspective)

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
		

	
	
	

	if is_on_floor() and direction != 0 and not is_sliding and not is_dashing:
		step_timer -= delta
		if step_timer <= 0:
			play_step_sound()
			step_timer = STEP_INTERVAL  # Reset timer
	
	
	if is_on_floor() and was_in_air:
		play_sound("landing")  

	was_in_air = not is_on_floor()  

	if not can_wrap and (not camera_perspective == camera_perspectives.NORMAL or camera_focus_bool == false):
		constrain_to_screen()

		
#|-------------------------------------------------------------------------|
#|------------------------------- Actions ---------------------------------|
#|-------------------------------------------------------------------------|


#|-------------------------------------------------------------------------|
#|-------------------------------- Dash -----------------------------------|
#|-------------------------------------------------------------------------|


func start_dash(direction: float) -> void:
	
	if is_dash_on_cooldown:
		return  
	is_dashing = true
	dash_timer = DASH_DURATION 
	play_sound("dash")
	
	GRAVITY = 0
	
	if direction != 0:
		velocity.x = DASH_SPEED * direction
	elif velocity.x != 0:
		velocity.x = DASH_SPEED * sign(velocity.x)
	else:
		velocity.x = DASH_SPEED * (1 if not animated_sprite.flip_h else -1)
		
	GRAVITY = 600
		
	is_dash_on_cooldown = true
	dash_cooldown_timer.start()
		
func _on_dash_cooldown_timeout() -> void:
	is_dash_on_cooldown = false  
	
func get_dash_cooldown_time_left() -> float:
	return dash_cooldown_timer.time_left if is_dash_on_cooldown else 0.0
	
func handle_dash(delta: float) -> void:
	dash_timer -= delta  
	if dash_timer <= 0:
		is_dashing = false 
		GRAVITY = 600
		velocity.x = 0  
		if not is_on_floor() or not is_on_ceiling():
			animated_sprite.play("jump")
	
#|-------------------------------------------------------------------------|
#|------------------------- Pulling and Pushing ---------------------------|
#|-------------------------------------------------------------------------|
	
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

#|-------------------------------------------------------------------------|
#|-------------------------------- Slide ----------------------------------|
#|-------------------------------------------------------------------------|

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

#|-------------------------------------------------------------------------|
#|----------------------------- Animations --------------------------------|
#|-------------------------------------------------------------------------|

func animations(direction: float) -> void:
	if (not is_on_floor() and not is_on_ceiling()) and not is_sliding and not is_dashing :
		if animated_sprite.animation != "jump": 
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


func adjust_collision_height(new_height: float) -> void:
	
	var height_difference = rect.size.y - new_height
	rect.size.y = new_height
	collision_shape.position.y += height_difference / 2
	
	
#|-------------------------------------------------------------------------|
#|----------------------------Wrapping Logic ------------------------------|
#|-------------------------------------------------------------------------|

func screen_wrap(camera_perpective) -> void:
	var camera_pos = camera.global_position
	var camera_zoom = camera.zoom
	var visible_width = screen_size.x / camera_zoom.x
	var visible_height = screen_size.y / camera_zoom.y

	var left_edge = camera_pos.x - visible_width / 2
	var right_edge = camera_pos.x + visible_width / 2
	var top_edge = camera_pos.y - visible_height / 2
	var bottom_edge = camera_pos.y + visible_height / 2
	
	if can_wrap:
		if camera_perpective == camera_perspectives.INVERTED:
			var center_x = (left_edge + right_edge) / 2
			var center_y = (top_edge + bottom_edge) / 2
			if global_position.x > right_edge:
				global_position.x = left_edge
				global_position.y = center_y - (global_position.y - center_y)
				reset_axial()
			elif global_position.x < left_edge:
				global_position.x = right_edge
				global_position.y = center_y - (global_position.y - center_y)
				reset_axial()
			if global_position.y > bottom_edge:
				global_position.y = top_edge
				global_position.x = center_x - (global_position.x - center_x)
				reset_axial()
			elif global_position.y < top_edge:
				global_position.y = bottom_edge
				global_position.x = center_x - (global_position.x - center_x)
				reset_axial()
				
		elif camera_perspective == camera_perspectives.GRAVITY:
			var center_x = (left_edge + right_edge) / 2
			var center_y = (top_edge + bottom_edge) / 2
			if global_position.x > right_edge:
				global_position.x = left_edge
				global_position.y = global_position.y
				camera_focus_bool = !camera_focus_bool
				toogle_gravity()
				reset_gravity()
			elif global_position.x < left_edge:
				global_position.x = right_edge
				global_position.y = center_y - (global_position.y - center_y)
				camera_focus_bool = !camera_focus_bool
				toogle_gravity()
				reset_gravity()
			if global_position.y > bottom_edge:
				print("Gravity nao faz")
				reset_gravity()
			elif global_position.y < top_edge:
				print("Gravity nao faz")
				reset_gravity()
			
		else:
			if global_position.x > right_edge:
				global_position.x = left_edge
				reset_focus()
			elif global_position.x < left_edge:
				global_position.x = right_edge
				reset_focus()
			if global_position.y > bottom_edge:
				global_position.y = top_edge
				reset_focus()
			elif global_position.y < top_edge:
				global_position.y = bottom_edge
				reset_focus()

				
func reset_focus() -> void:
	Input.action_press("focus_Camera")
	
func reset_gravity() -> void:
	Input.action_press("gravity_toggle")
	
func reset_axial() -> void:
	Input.action_press("axial_toggle")

#|-------------------------------------------------------------------------|
#|---------------------- Camera Collision Checker -------------------------|
#|-------------------------------------------------------------------------|

func set_collision_checker_pos(player_local_pos) -> void:
	if camera_perspective == camera_perspectives.INVERTED:
		mirrored_pos = Vector2(-player_local_pos.x, -player_local_pos.y -15)
	elif(camera_perspective == camera_perspectives.NORMAL):
		mirrored_pos = Vector2(-player_local_pos.x, player_local_pos.y -15)
	elif(camera_perspective == camera_perspectives.GRAVITY):
		mirrored_pos = Vector2(-player_local_pos.x, player_local_pos.y - 15)
	
	collision_checker.global_position = camera.to_global(mirrored_pos)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"): #Para a box não colidir com o proprio player
		#print("NAO PODE")
		can_wrap = false
		pass 

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		#print("PODE")
		can_wrap = true
		pass 
	
func constrain_to_screen() -> void: # Impossibilita o player de sair das bordas do ecrã
	var camera_pos = camera.global_position
	var camera_zoom = camera.zoom
	var visible_width = screen_size.x / camera_zoom.x
	var visible_height = screen_size.y / camera_zoom.y

	var left_edge = camera_pos.x - visible_width / 2
	var right_edge = camera_pos.x + visible_width / 2
	var top_edge = camera_pos.y - visible_height / 2
	var bottom_edge = camera_pos.y + visible_height / 2

	global_position.x = clamp(global_position.x, left_edge + 15, right_edge -15)
	global_position.y = clamp(global_position.y, top_edge - 15, bottom_edge + 15)

#|-------------------------------------------------------------------------|
#|------------------------------ Gravity Logic ----------------------------|
#|-------------------------------------------------------------------------|
	
func toogle_gravity():
	if gravity_toggle:
		inversion *= -1
		animated_sprite.scale.y = abs(animated_sprite.scale.y) * inversion
		
		
#|-------------------------------------------------------------------------|
#|----------------------------- Input Binds -------------------------------|
#|-------------------------------------------------------------------------|

func handle_inputs(direction,delta):
	
	# Checkpoints (ESC)
	if Input.is_action_just_pressed("checkpoint"):
		death_bool = false
	
	# Pulling (C)
	if Input.is_action_just_pressed("pull"):
		is_pulling = true
	
	if Input.is_action_just_released("pull"):
		is_pulling = false

	# X-ray (X)
	if Input.is_action_just_pressed("x_ray_camera_toggle"):
		toggle_xray()
		
	# Jump (Space)
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_ceiling()):
		play_sound("jump")
		velocity.y = JUMP_VELOCITY * inversion
		
	# Dash (shift)
	if Input.is_action_just_pressed("dash") and not is_dashing:
		
		start_dash(direction)
		
	# Slide (ctrl)
	if Input.is_action_just_pressed("slide") and (is_on_floor() or is_on_ceiling()) and not is_sliding and (velocity.x != 0):
		start_slide(direction)
	
	if is_sliding:
		handle_slide(delta)
		
	# Cameras
	# Focus Camera (F)
	if (Input.is_action_just_pressed("focus_Camera")):
		camera_focus_bool = !camera_focus_bool
		gravity_toggle = false
		print("camera focus bool state: ", camera_focus_bool)
		
	# Gravity Camera (G)
	if Input.is_action_just_pressed("gravity_toggle"):
		gravity_toggle = !gravity_toggle
		camera_focus_bool = true
		#print("camera focus bool state: ", camera_focus_bool)
		camera_perspective = camera_perspectives.GRAVITY
	
	# Axial Camera (H)
	if Input.is_action_just_pressed("axial_toggle"):
		camera_perspective = camera_perspectives.INVERTED
		
	if Input.is_action_just_pressed("camera_1"):
		camera_perspective = camera_perspectives.NORMAL
	
#|-------------------------------------------------------------------------|
#|------------------------------ X-ray Logic ------------------------------|
#|-------------------------------------------------------------------------|
func toggle_xray() -> void:
	if current_battery <= 0:
		xray_active = false
		x_ray_shadder.visible = false
		emit_signal("xray_toggled", xray_active)
		return
		
	else:
		xray_active = !xray_active
		x_ray_shadder.visible = xray_active
		
		if xray_active:
			xray_timer.start()
		else:
			xray_timer.stop()
			
		emit_signal("xray_toggled", xray_active)
	
func _on_xray_timer_timeout() -> void:
	if xray_active:
		current_battery -= xray_timer.wait_time
		current_battery = clamp(current_battery, 0, max_battery)
		battery.value = current_battery

		if current_battery <= 0:
			toggle_xray()
			
#|-------------------------------------------------------------------------|
#|----------------------------- Death Logic -------------------------------|
#|-------------------------------------------------------------------------|

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
	
func play_sound(sound_name: String):
	if sound_name in sound_dict:
		audio_player.stream = sound_dict[sound_name]
		audio_player.play()
	else:
		print("Sound not found: " + sound_name)
		
func play_step_sound() -> void:
	if not audio_player:
		print("Error: audio_player node is not available.")
		return

	if "step" in sound_dict:  # Check if step sound exists in dictionary
		audio_player.stream = sound_dict["step"]

		# Randomize pitch
		audio_player.pitch_scale = rng.randf_range(0.9, 1.1)  # Adjust pitch randomness

		audio_player.play()
	else:
		print("Error: Step sound not found in sound_dict")
	
