extends Label

@export var player: Node

func _ready() -> void:
	player.connect("xray_toggled", Callable(self, "_on_xray_toggled"))

func _on_xray_toggled(xray_active):
	visible = xray_active
