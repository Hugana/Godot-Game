extends Node

@export var correct_sequence: Array = ["Button1", "Button3", "Button2"]
var current_sequence: Array = []
var interactables: Array = []

signal puzzle_solved

@export var timer_display: Node

func _ready():
	interactables = get_tree().get_nodes_in_group("puzzle1")
	for interactable in interactables:
		if interactable.is_in_group("interactable"):
			interactable.connect("interacted", Callable(self, "_on_interactable_toggled"))
	
	if timer_display:
		print("connected")
		connect("puzzle_solved", Callable(timer_display, "_on_puzzle_solved"))


func _on_interactable_toggled(state: bool, button_name: String):
	if state:
		current_sequence.append(button_name)
		print("Current sequence:", current_sequence)
		_check_sequence()

func _check_sequence():
	for i in range(min(len(current_sequence), len(correct_sequence))):
		if current_sequence[i] != correct_sequence[i]:
			print("Wrong sequence!")
			_reset_sequence()
			return
		
	if len(current_sequence) == len(correct_sequence):
		print("Puzzle solved!")
		emit_signal("puzzle_solved")
		_on_puzzle_solved()

func _reset_sequence():
	print("Resetting sequence.")
	current_sequence.clear()

func _on_puzzle_solved():
	print("Unlocking the passage!")
	
