extends Node

@export var correct_sequence: Array = ["Button1", "Button3", "Button2"]  # Order to solve the puzzle
var current_sequence: Array = []  # Track the player's toggling order
var interactables: Array = []  # Holds the interactable nodes

signal puzzle_solved  # Emitted when the puzzle is solvedd

func _ready():
	# Populate the interactables array using the "puzzle1" group
	interactables = get_tree().get_nodes_in_group("puzzle1")
	for interactable in interactables:
		if interactable.is_in_group("interactable"):
			interactable.connect("interacted", Callable(self, "_on_interactable_toggled"))

func _on_interactable_toggled(state: bool, button_name: String):
	if state:  # Record toggling only when turned "on"
		current_sequence.append(button_name)
		print("Current sequence:", current_sequence)
		_check_sequence()

func _check_sequence():
	# Check if the current sequence matches the correct sequence so far
	for i in range(min(len(current_sequence), len(correct_sequence))):
		if current_sequence[i] != correct_sequence[i]:
			print("Wrong sequence!")
			_reset_sequence()
			return
	
	# If the sequence is complete and correct
	if len(current_sequence) == len(correct_sequence):
		print("Puzzle solved!")
		emit_signal("puzzle_solved")
		_on_puzzle_solved()

func _reset_sequence():
	print("Resetting sequence.")
	current_sequence.clear()

func _on_puzzle_solved():
	# Handle puzzle solved logic (e.g., unlock a door, enable a passage, etc.)
	print("Unlocking the passage!")
