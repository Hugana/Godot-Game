extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var interactables = get_tree().get_nodes_in_group("interactable")
	for interactable in interactables:
		interactable.connect("interacted", Callable(self, "_on_interactable_interacted"))


func _on_interactable_interacted(state: bool, button_name : String) -> void:
	SceneHandler.got_to_level2()
