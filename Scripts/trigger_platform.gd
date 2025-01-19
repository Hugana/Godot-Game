extends Area2D

signal activated
signal deactivated

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("movable"):
		activated.emit(name)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("movable"):
		deactivated.emit(name)
