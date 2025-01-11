extends Control


@onready var main_menu: VBoxContainer = $"Main Menu"
@onready var start: VBoxContainer = $Start
@onready var select_level: VBoxContainer = $"Select Level"
@onready var options: VBoxContainer = $Options

func _on_start_pressed() -> void:
	main_menu.visible = false
	start.visible = true
	select_level.visible = false
	options.visible = false

func _on_options_pressed() -> void:
	main_menu.visible = false
	start.visible = false
	select_level.visible = false
	options.visible = true

func _on_select_level_pressed() -> void:
	main_menu.visible = false
	start.visible = false
	select_level.visible = true
	options.visible = false

func _on_back_pressed() -> void:
	if start.visible == true:
		main_menu.visible = true
		start.visible = false
		select_level.visible = false
		options.visible = false
	elif options.visible == true:
		main_menu.visible = true
		start.visible = false
		select_level.visible = false
		options.visible = false
	else:
		main_menu.visible = false
		start.visible = true
		select_level.visible = false
		options.visible = false


func _on_new_game_pressed() -> void:
	SceneHandler.got_to_level1()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_test_game_pressed() -> void:
	SceneHandler.got_to_level2()
