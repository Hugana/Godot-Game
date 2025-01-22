extends Node

var menu_scene = "res://Scenes/UI/menu.tscn"
var level_1 = "res://Scenes/Game.tscn"
var level_2 = "res://Scenes/Level1.tscn"
var level_3

func got_to_menu():
	get_tree().change_scene_to_file(menu_scene)
	
func got_to_level1():
	get_tree().change_scene_to_file(level_1)

func got_to_level2():
	get_tree().change_scene_to_file(level_2)

func got_to_level3():
	get_tree().change_scene_to_file(level_3)
