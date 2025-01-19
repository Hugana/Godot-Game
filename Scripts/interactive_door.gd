extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var isOpen = false
@export var trigger_name : String

signal toggle_door

func _ready() -> void:
	open_or_close()
	
	var trigger_platforms = get_tree().get_nodes_in_group("trigger_platforms")

	for trigger_platform in trigger_platforms:
		trigger_platform.connect("activated", Callable(self, "_on_trigger_platform_activated"))
		trigger_platform.connect("deactivated", Callable(self, "_on_trigger_platform_deactivated"))
	
func open():
	if !isOpen:
		animated_sprite.play("Open")
		isOpen = true
		collision_shape_2d.set_deferred("disabled", isOpen)


func close():
	if isOpen:
		animated_sprite.play("Close")
		isOpen = false
		collision_shape_2d.set_deferred("disabled", isOpen)


func open_or_close():
	if isOpen:
		animated_sprite.play("Open")
		isOpen = true
	else:
		animated_sprite.play("Close")
		isOpen = false
		
	collision_shape_2d.set_deferred("disabled", isOpen)


func _on_toggle_door() -> void:
	isOpen = !isOpen
	open_or_close()


func _on_trigger_platform_activated(name) -> void:
	if name == trigger_name:
		_on_toggle_door()
	
func _on_trigger_platform_deactivated(name) -> void:
	if name == trigger_name:
		_on_toggle_door()
		
