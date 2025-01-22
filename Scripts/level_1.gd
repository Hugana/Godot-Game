extends Node

@export var timer_display: Node

# Boxes
var boxes_solved = false
var platform_states: Array = [false, false, false]

# Levers
var levers_solved = false
@export var correct_sequence: Array = ["Button1", "Button3", "Button2"]
var current_sequence: Array = []
var interactables: Array = []

var level_puzzles: Array = ["boxes", "levers"]
var puzzles_solved: Array = []

var objectives: Array = ["boxes", "traverse", "levers", "escape"]

signal puzzle_solved(puzzle_name)
signal level_complete
signal obj_update

# Sounds
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var success_sound: AudioStream = preload("res://Assets/sounds/success.wav")
@onready var fail_sound: AudioStream = preload("res://Assets/sounds/fail.wav")

# Escape label
@onready var escape: Label = $Puzzle3/escape
@onready var escape_collision: CollisionShape2D = $Puzzle3/escape/Area2D/CollisionShape2D


func _ready():
	#boxes
	var box_puzzle_elements = get_tree().get_nodes_in_group("puzzle1")
	
	for element in box_puzzle_elements:
		if element.is_in_group("platform"):
			print("recognized platform")
			element.connect("activated", Callable(self, "_on_platform_activated"))
			element.connect("deactivated", Callable(self, "_on_platform_deactivated"))
	
	#levers
	interactables = get_tree().get_nodes_in_group("puzzle3")
	
	for interactable in interactables:
		if interactable.is_in_group("interactable"):
			interactable.connect("interacted", Callable(self, "_on_interactable_toggled"))
	
	if timer_display:
		connect("puzzle_solved", Callable(timer_display, "_on_puzzle_solved"))
		
	update_objective("boxes", "0")
	
	escape_collision.disabled = true

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
	if !boxes_solved:
		print("platform states: ", platform_states)
		if not false in platform_states:
			puzzle_solved.emit("boxes")
			update_objective("traverse")
		else:
			update_objective("boxes", str(platform_states.count(true)))


func _on_interactable_toggled(state: bool, button_name: String):
	if state:
		if button_name in correct_sequence:
			if button_name not in current_sequence:
				current_sequence.append(button_name)
				print("Current sequence:", current_sequence)
				_check_sequence()
			elif  button_name in current_sequence:
				_reset_sequence()
	if button_name == "Exit_Level":
		exit_level()
			
func _check_sequence():
	if !levers_solved:
		for i in range(min(len(current_sequence), len(correct_sequence))):
			if current_sequence[i] != correct_sequence[i]:
				print("Wrong sequence!")
				_reset_sequence()
				return
			else: 
				_play_sound(success_sound)
			
		if len(current_sequence) == len(correct_sequence):
			print("Levers puzzle solved!")
			puzzle_solved.emit("levers")
			update_objective("escape")
		else:
			print("Progres: ", len(current_sequence))
			update_objective("levers", len(current_sequence))

func _reset_sequence():
	print("Resetting sequence.")
	current_sequence.clear()
	update_objective("levers", "0")
	_play_sound(fail_sound)

func _on_puzzle_solved(puzzle):
	print("puzzle ", puzzle, " complete")
	puzzle_solved.emit()
	puzzles_solved.append(puzzle)
	_check_level_complete()
	
func _check_level_complete():
	if len(puzzles_solved) == len(level_puzzles):
		level_complete.emit()
	
func update_objective(objective, progress = false):
	#print("updating obj: ", objective, "progress: ", progress)
	if objective in objectives:
		if progress:
			#print("with progress")
			obj_update.emit(objective, progress)
		#print("without progress")
		obj_update.emit(objective, progress)
	else:
		print("Objective not set")

func exit_level():
	if boxes_solved and levers_solved:
		SceneHandler.got_to_menu()
	else:
		print("level not complete!")
		
func _play_sound(sound: AudioStream):
	audio_player.stream = sound
	audio_player.volume_db = -10.0
	audio_player.play()

func _on_level_complete() -> void:
	escape_collision.disabled = false
