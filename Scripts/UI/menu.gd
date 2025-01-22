extends Control


@onready var main_menu: VBoxContainer = $"Main Menu"
@onready var select_level: VBoxContainer = $"Select Level"
@onready var options: VBoxContainer = $Options

func _on_options_pressed() -> void:
	main_menu.visible = false
	select_level.visible = false
	options.visible = true

func _on_back_pressed() -> void:
	if 	select_level.visible == true:
		main_menu.visible = true
		select_level.visible = false
		options.visible = false
	elif options.visible == true:
		main_menu.visible = true
		select_level.visible = false
		options.visible = false
	else:
		main_menu.visible = false
		select_level.visible = false
		options.visible = false


func _on_new_game_pressed() -> void:
	SceneHandler.got_to_level_tutorial()
	pass # Replace with function body.


func _on_level_pressed() -> void:
	SceneHandler.got_to_level_tutorial()
	pass # Replace with function body.


func _on_level_1_pressed() -> void:
	SceneHandler.got_to_level1()
	pass # Replace with function body.


func _on_full_screen_pressed() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		# Set to fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# Set to windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_level_select_pressed() -> void:
	main_menu.visible = false
	select_level.visible = true
	options.visible = false
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	SceneHandler.got_to_menu()
	pass # Replace with function body.


func _on_death_tutorial_pressed() -> void:
	SceneHandler.got_to_level_tutorial()
	pass # Replace with function body.


func _on_death_main_menu_pressed() -> void:
	SceneHandler.got_to_menu()
	pass # Replace with function body.


func _on_death_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_death_1_level_1_pressed() -> void:
	SceneHandler.got_to_level1()
	pass # Replace with function body.


func _on_death_1_main_menu_pressed() -> void:
	SceneHandler.got_to_menu()
	pass # Replace with function body.


func _on_death_1_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
