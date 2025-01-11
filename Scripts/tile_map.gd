extends TileMap

var x_ray_active = false
var tangible_layer = 0  # Replace with your tangible layer index
@export var player: CharacterBody2D  # Make sure this is the correct node type

func _ready():
	if player:
		player.connect("xray_toggled", Callable(self, "_on_xray_toggled"))

func _process(delta):
	# If you want to handle something else in the TileMap, you can do it here.
	pass

# Handle when the X-ray is toggled
func _on_xray_toggled(xray_status: bool) -> void:
	x_ray_active = xray_status
	print("X-Ray Active:", x_ray_active)

	# Ensure the player node is not Nil before proceeding
	if player:
		# Modify the player's collision mask based on X-ray mode
		if x_ray_active:
			# Disable collision with the Tangible layer (layer 1 in this case)
			player.collision_mask &= ~(1 << tangible_layer)
			print("Player collision with Tangible layer disabled.")
		else:
			# Restore collision with the Tangible layer (layer 1)
			player.collision_mask |= (1 << tangible_layer)
			print("Player collision with Tangible layer enabled.")
	else:
		print("Warning: Player node is not assigned!")
