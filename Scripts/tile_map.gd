extends TileMap

var x_ray_active = false
var tangible_layer = 0
@export var player: CharacterBody2D
@onready var collision_detector: Area2D = $"../Player/Area2D"

func _ready():
	if player:
		player.connect("xray_toggled", Callable(self, "_on_xray_toggled"))

func _on_xray_toggled(xray_status: bool) -> void:
	x_ray_active = xray_status
	print("X-Ray Active:", x_ray_active)

	if player:
		if x_ray_active:
			player.collision_mask &= ~(1 << 0)
			print("Player collision with Tangible layer disabled.")
		else:
			player.collision_mask |= (1 << 0)
			print("Player collision with Tangible layer enabled.")
	elif collision_detector:
		if x_ray_active:
			collision_detector.collision_mask &= ~(1 << 0)
			print("Player collision with Tangible layer disabled.")
		else:
			collision_detector.collision_mask |= (1 << 0)
			print("Player collision with Tangible layer enabled.")
	else:
		print("Warning: Player node is not assigned!")
