extends Area2D

@onready var level_1: Node2D = $".."

var has_traversed = false

func _on_body_entered(body: Node2D) -> void:
	if !has_traversed:
		if body.name == 'Player':
			level_1.update_objective("levers", "0")
	has_traversed = true
