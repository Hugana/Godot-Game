extends TileMap

# Signal whether X-Ray mode is active
var x_ray_active = false
var tangible_layer = 0  # Replace with your tangible layer index

# Add a reference to the player's collision (assuming player is a CharacterBody2D)
@export var player: CharacterBody2D  # Make sure this is the correct node type

func _process(delta):
	# Check if the toggle input is pressed
	if Input.is_action_just_pressed("x_ray_camera_toggle"):
		toggle_x_ray_mode()
		print("X-ray toggled")

func toggle_x_ray_mode():
	x_ray_active = !x_ray_active
	print("X-Ray Active:", x_ray_active)

	# Ensure the player node is not Nil before proceeding
	if player:
		# Modify the player's collision mask based on X-ray mode
		if x_ray_active:
			# Disable collision with the Collision layer (layer 0)
			player.collision_mask &= ~(1 << 1)
			print("Player collision with Tangible layer disabled.")
		else:
			# Restore collision with the Collision layer (layer 0)
			player.collision_mask |= (1 << 1) 
			print("Player collision with Tangible layer enabled.")
	else:
		print("Warning: Player node is not assigned!")
