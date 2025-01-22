extends Label

@export var start_time: int = 180
var remaining_time: int
@export var current_lvl: String 

@onready var timer: Timer = $"../Timer"

func _ready():
	remaining_time = start_time
	_update_label()

	timer.connect("timeout", _on_Timer_timeout)
	timer.start()

func _on_Timer_timeout():
	if remaining_time > 0:
		remaining_time -= 1
		_update_label()
	else:
		_on_time_up()

func _update_label():
	# Update the label to show the remaining time in MM:SS format
	var minutes = remaining_time / 60
	var seconds = remaining_time % 60
	text = String("%02d:%02d") % [minutes, seconds]  # Format as MM:SS

func _on_time_up():
	
	print("Time's up!")
	
	if current_lvl == "tutorial":
		SceneHandler.go_to_deathScreen_Tutorial()
	elif current_lvl == "lvl1":
		SceneHandler.go_to_deathScreen_lvl1()
	
func _on_puzzle_solved():
	print("Puzzle solved! Adding 120 seconds to the timer.")
	remaining_time += 120
	_update_label()
