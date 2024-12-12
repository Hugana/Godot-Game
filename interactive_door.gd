extends AnimatedSprite2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var isOpen = false

signal toggle_door # Pode ser usado por outros nodes, funciona como um trigger

func _ready() -> void:
	# Verifica que a porta é inicializada com o valor certo
	update_door_state()

func open_or_close():
	if isOpen:
		play("Open")
	else:
		play("Close")

	# define a colisão conforme o valor da variável
	collision_shape_2d.disabled = isOpen

func _on_toggle_door() -> void:
	# Muda o estado da variável e atualiza o valor da porta
	isOpen = !isOpen
	update_door_state()

func update_door_state():
	# Chama a função que abre ou fecha a porta
	open_or_close()
