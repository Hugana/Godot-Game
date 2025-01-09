extends Area2D

@export var is_one_shot: bool = true
@export var signal_name: String = "interacted"

signal interacted(state: bool)

var is_used: bool = false

func _ready():
	if !has_signal(signal_name):
		add_user_signal(signal_name)

func _process(delta):
	if Input.is_action_just_pressed("interact") and is_player_in_area():
		interact()

func interact():
	if is_one_shot and is_used:
		return
	is_used = true if is_one_shot else is_used
	emit_signal(signal_name, is_one_shot or !is_used, name)

func is_player_in_area() -> bool:
	for body in get_overlapping_bodies():
		print(body)
		if body.name == "Player":  # Adjust to your player's node name
			return true
	return false
