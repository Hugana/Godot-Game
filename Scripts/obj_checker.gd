extends Area2D

@onready var level_1: Node2D = $".."

var has_traversed = false

signal add_time
@onready var timer_display: Label = $"../UI/TimerDisplay"

func _ready():
	connect("add_time", Callable(timer_display, "_on_add_2mins"))

func _on_body_entered(body: Node2D) -> void:
	if not has_traversed:
		if body.name == 'Player':
			print("Traverse complete")
			level_1.update_objective("levers", "0")
			has_traversed = true
			add_time.emit()
