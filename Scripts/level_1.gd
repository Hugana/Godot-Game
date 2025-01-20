extends Node

@export var timer_display: Node

# Boxes
var platform_states: Array = [false, false, false]

# Levers

@export var correct_sequence: Array = ["Button1", "Button3", "Button2"]
var current_sequence: Array = []
var interactables: Array = []

var level_puzzles: Array = ["boxes", "levers"]
var puzzles_solved: Array = []

signal puzzle_solved(puzzle_name)
signal level_complete

func _ready():
	var box_puzzle_elements = get_tree().get_nodes_in_group("puzzle1")
	for element in box_puzzle_elements:
		if element.is_in_group("platform"):
			print("recognized platform")
			element.connect("activated", Callable(self, "_on_platform_activated"))
			element.connect("deactivated", Callable(self, "_on_platform_deactivated"))
	
	
	interactables = get_tree().get_nodes_in_group("puzzle3")
	for interactable in interactables:
		if interactable.is_in_group("interactable"):
			interactable.connect("interacted", Callable(self, "_on_interactable_toggled"))
	
	if timer_display:
		connect("puzzle_solved", Callable(timer_display, "_on_puzzle_solved"))

#receber os sinais das plataformas
func _on_platform_activated(platform_name):
	print("activated", platform_name)
	if platform_name == "Pressure_1":
		platform_states[0] = true
	elif platform_name == "Pressure_2":
		platform_states[1] = true
	elif platform_name == "Pressure_3":
		platform_states[2] = true
	check_platforms()
	
func _on_platform_deactivated(platform_name):
	print("deactivated", platform_name)
	if platform_name == "Pressure_1":
		platform_states[0] = false
	elif platform_name == "Pressure_2":
		platform_states[1] = false
	elif platform_name == "Pressure_3":
		platform_states[2] = false
	check_platforms()

#formular uma lista que verifica se todas as plataformas estão pressionadas ao mesmo tempo
func check_platforms():
	print("platform states: ", platform_states)
	if not false in platform_states:
		puzzle_solved.emit("boxes")


func _on_interactable_toggled(state: bool, button_name: String):
	if state:
		if button_name in correct_sequence:
			current_sequence.append(button_name)
			print("Current sequence:", current_sequence)
			_check_sequence()
		else:
			pass # logica de outros botões
			
func _check_sequence():
	for i in range(min(len(current_sequence), len(correct_sequence))):
		if current_sequence[i] != correct_sequence[i]:
			print("Wrong sequence!")
			_reset_sequence()
			return
		
	if len(current_sequence) == len(correct_sequence):
		print("Levers puzzle solved!")
		puzzle_solved.emit("levers")

func _reset_sequence():
	print("Resetting sequence.")
	current_sequence.clear()

func _on_puzzle_solved(puzzle):
	print("puzzle ", puzzle, " complete")
	puzzle_solved.emit()
	puzzles_solved.append(puzzle)
	_check_level_complete()
	
func _check_level_complete():
	if len(puzzles_solved) == len(level_puzzles):
		level_complete.emit()
	
#coiso
