extends TileMap

# Signal whether X-Ray mode is active
var x_ray_active = false

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
			# Disable collision with the Tangible layer (layer 2)
			player.collision_mask &= ~(1 << 1)  # Remove layer 2 (Tangible) collisions
			print("Player collision with Tangible layer disabled.")
		else:
			# Restore collision with the Tangible layer (layer 2)
			player.collision_mask |= (1 << 1)  # Add layer 2 (Tangible) collisions
			print("Player collision with Tangible layer enabled.")
	else:
		print("Warning: Player node is not assigned!")

	var tangible_layer = 2  # Replace with your tangible layer index

	# Iterate through all used cells in the tangible layer
	for cell_pos in get_used_cells(tangible_layer):
		toggle_tile_properties(cell_pos, tangible_layer)

func toggle_tile_properties(cell_pos, layer):
	# Get the tile ID
	var tile_id = get_cell_source_id(layer, cell_pos)

	if tile_id >= 0:  # Ensure it's a valid tile
		# Adjust collision mask of the player (done in toggle_x_ray_mode())
		# Adjust opacity only for tangible tiles
		set_tile_opacity(cell_pos, x_ray_active)

func set_tile_opacity(cell_pos, x_ray_active):
	# Placeholder for tile opacity logic (if needed)
	pass
