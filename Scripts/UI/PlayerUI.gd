extends CanvasLayer  # Handles UI for displaying camera icons

# Icon nodes
@onready var focus_icon: TextureRect = $CameraIcons/FocusIcon
@onready var grav_icon: TextureRect = $CameraIcons/GravIcon
@onready var axial_icon: TextureRect = $CameraIcons/AxialIcon
@onready var dash_cooldown: TextureProgressBar = $DashCooldown
@onready var current_objective: Label = $CurrentObjective

@export var player: Node

# Camera states
var is_focus_active: bool = false
var is_gravity_active: bool = false
var is_axial_active: bool = false

# Opacity settings
const ACTIVE_OPACITY: float = 1.0
const INACTIVE_OPACITY: float = 0.3

func _ready():
	_update_icon_opacity(null)
	
	dash_cooldown.visible = false

func _process(delta):
	# Handle key inputs for toggling cameras
	if Input.is_action_just_pressed("focus_Camera"):
		_toggle_camera("focus")
	elif Input.is_action_just_pressed("gravity_toggle"):
		_toggle_camera("gravity")
	elif Input.is_action_just_pressed("axial_toggle"):
		_toggle_camera("axial")
		
	if dash_cooldown.visible and player and player.has_method("get_dash_cooldown_time_left"):
		var cooldown_time_left = player.get_dash_cooldown_time_left()
		dash_cooldown.max_value = 2.0
		dash_cooldown.value = cooldown_time_left

		if cooldown_time_left <= 0.0:
			dash_cooldown.visible = false

	# Check for dash input and handle cooldown
	if Input.is_action_just_pressed("dash"):
		#print("reconheceu dash")
		_handle_dash_input()

func _toggle_camera(camera_type: String):
	# Logic to toggle cameras
	match camera_type:
		"focus":
			is_focus_active = not is_focus_active
			if is_focus_active:
				is_gravity_active = false
				is_axial_active = false
		"gravity":
			is_gravity_active = not is_gravity_active
			if is_gravity_active:
				is_focus_active = false
				is_axial_active = false
		"axial":
			is_axial_active = not is_axial_active
			if is_axial_active:
				is_focus_active = false
				is_gravity_active = false

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
