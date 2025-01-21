extends CanvasLayer  # Handles UI for displaying camera icons

# Icon nodes
@onready var focus_icon: TextureRect = $CameraIcons/FocusIcon
@onready var grav_icon: TextureRect = $CameraIcons/GravIcon
@onready var axial_icon: TextureRect = $CameraIcons/AxialIcon
@onready var dash_cooldown: TextureProgressBar = $DashCooldown
@onready var current_objective: Label = $CurrentObjective
@onready var camera_2d: Camera2D = $"../Camera2D"

@export var player: Node

# Camera states
var is_focus_active: bool = false
var is_gravity_active: bool = false
var is_axial_active: bool = false

# Opacity settings
const ACTIVE_OPACITY: float = 1.0
const INACTIVE_OPACITY: float = 0.3

# Camera mode states
var last_camera_mode: int = -1  # Initialize to an invalid state


func _ready():
	_update_icon_opacity(null)
	
	dash_cooldown.visible = false

func _process(delta):
	# Check for a change in camera mode
	if camera_2d.camera_mode != last_camera_mode:
		# Update the active camera only if the mode has changed
		match camera_2d.camera_mode:
			camera_2d.CameraMode.UNFOCUSED:
				_toggle_camera("focus")
			camera_2d.CameraMode.GRAVITY:
				_toggle_camera("gravity")
			camera_2d.CameraMode.AXIAL:
				_toggle_camera("axial")
			_:
				# Handle the "no camera selected" case
				_toggle_camera("none")
		
		# Update the last known camera mode
		last_camera_mode = camera_2d.camera_mode
	
	# Handle dash cooldown visibility
	if dash_cooldown.visible and player and player.has_method("get_dash_cooldown_time_left"):
		var cooldown_time_left = player.get_dash_cooldown_time_left()
		dash_cooldown.max_value = 2.0
		dash_cooldown.value = cooldown_time_left

		if cooldown_time_left <= 0.0:
			dash_cooldown.visible = false

	# Check for dash input and handle cooldown
	if Input.is_action_just_pressed("dash"):
		_handle_dash_input()

func _toggle_camera(camera_type: String):
	# Logic to toggle cameras
	match camera_type:
		"focus":
			is_focus_active = true
			is_gravity_active = false
			is_axial_active = false
		"gravity":
			is_focus_active = false
			is_gravity_active = true
			is_axial_active = false
		"axial":
			is_focus_active = false
			is_gravity_active = false
			is_axial_active = true
		"none":
			is_focus_active = false
			is_gravity_active = false
			is_axial_active = false

	# Update the icon opacity based on the new states
	if is_focus_active:
		_update_icon_opacity(focus_icon)
	elif is_gravity_active:
		_update_icon_opacity(grav_icon)
	elif is_axial_active:
		_update_icon_opacity(axial_icon)
	else:
		_update_icon_opacity(null)  # No active camera

func _update_icon_opacity(active_icon: TextureRect):
	# Reset all icons to inactive opacity
	focus_icon.modulate.a = INACTIVE_OPACITY
	grav_icon.modulate.a = INACTIVE_OPACITY
	axial_icon.modulate.a = INACTIVE_OPACITY

	# Set the active icon to full opacity if applicable
	if active_icon:
		active_icon.modulate.a = ACTIVE_OPACITY

func _handle_dash_input():
	if player and player.has_method("get_dash_cooldown_time_left"):
		var cooldown_time = player.get_dash_cooldown_time_left()

		if cooldown_time >= 0.0:
			dash_cooldown.visible = true
			dash_cooldown.max_value = 2.0
			dash_cooldown.value = cooldown_time


func _on_level_1_obj_update(objective, progress) -> void:
	var obj_text : String
	
	if objective == "boxes":
		obj_text = "Activate all of the platforms"
		current_objective.text = obj_text
	if objective == "traverse":
		obj_text = "Find a way to keep moving"
		current_objective.text = obj_text
	if objective == "levers":
		obj_text = "Activate all of the devices in the correct order"
		current_objective.text = obj_text
	if objective == "escape":
		obj_text = "Find a way out"
		current_objective.text = obj_text
	if progress:
		current_objective.text += "(" + str(progress) + "/3)"
