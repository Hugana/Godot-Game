extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var isOpen = false

signal toggle_door # Pode ser usado por outros nodes, funciona como um trigger

func _ready() -> void:
	# Verifica que a porta é inicializada com o valor certo
	update_door_state()
	
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
	else:
		animated_sprite.play("Close")

	# define a colisão conforme o valor da variável
	collision_shape_2d.set_deferred("disabled", isOpen)


func _on_toggle_door() -> void:
	# Muda o estado da variável e atualiza o valor da porta
	isOpen = !isOpen
	update_door_state()

func update_door_state():
	# Chama a função que abre ou fecha a porta
	open_or_close()


func _on_trigger_platform_activated() -> void:
	open()
	
func _on_trigger_platform_deactivated() -> void:
	close()
