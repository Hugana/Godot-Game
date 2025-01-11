extends CanvasLayer  # Handles UI for displaying camera icons

# Icon nodes
@onready var focus_icon: TextureRect = $CameraIcons/FocusIcon
@onready var grav_icon: TextureRect = $CameraIcons/GravIcon
@onready var axial_icon: TextureRect = $CameraIcons/AxialIcon

# Camera states
var is_focus_active: bool = false
var is_gravity_active: bool = false
var is_axial_active: bool = false

# Opacity settings
const ACTIVE_OPACITY: float = 1.0
const INACTIVE_OPACITY: float = 0.3

func _ready():
	# Initialize default state (all inactive)
	_update_icon_opacity(null)

func _process(delta):
	# Handle key inputs for toggling cameras
	if Input.is_action_just_pressed("focus_Camera"):
		_toggle_camera("focus")
	elif Input.is_action_just_pressed("gravity_toggle"):
		_toggle_camera("gravity")
	elif Input.is_action_just_pressed("axial_toggle"):
		_toggle_camera("axial")

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
