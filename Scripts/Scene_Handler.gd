extends Node

var menu_scene = "res://Scenes/UI/menu.tscn"
var tutorial = "res://Scenes/Game.tscn"
var level_1 = "res://Scenes/Level1.tscn"


func got_to_menu():
	get_tree().change_scene_to_file(menu_scene)
	
func got_to_level1():
	get_tree().change_scene_to_file(level_1)

func got_to_level_tutorial():
	get_tree().change_scene_to_file(tutorial)
