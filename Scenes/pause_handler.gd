extends Node

@onready var box: VBoxContainer = $VBoxContainer
@onready var background: TextureRect = $TextureRect
@export var current_lvl: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Ensures input works even when paused
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	pass


func toggle_pause():
	get_tree().paused = !get_tree().paused  # Toggle game pause state
 	#pause_menu.visible = get_tree().paused  # Show/hide pause menu
	box.visible = !box.visible
	background.visible = !background.visible

	# Optional: Change UI visibility for clarity
	if get_tree().paused:
		print("Game Paused")
	else:
		print("Game Resumed")


func _on_resume_pressed() -> void:
	toggle_pause()
	pass # Replace with function body.


func _on_restart_level_pressed() -> void:
	if current_lvl == "tutorial":
		SceneHandler.got_to_level_tutorial()
	elif current_lvl == "lvl1":
		SceneHandler.got_to_level1()
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	SceneHandler.got_to_menu()
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
