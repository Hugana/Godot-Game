extends Node

@export var checkpoints: Array[Area2D]  # List of checkpoints
@export var player: CharacterBody2D

var current_checkpoint: Vector2 = Vector2.ZERO  # Stores the last checkpoint position

func _process(delta: float) -> void:
	for checkpoint in checkpoints:
		if checkpoint:
			for body in checkpoint.get_overlapping_bodies():
				if body == player:
					current_checkpoint = checkpoint.global_position
					#print("Checkpoint reached at:", current_checkpoint)

	# Teleport if the player presses the "checkpoint" action
	if Input.is_action_just_pressed("checkpoint"):
		if current_checkpoint != Vector2.ZERO:
			teleport_to_checkpoint()


func teleport_to_checkpoint() -> void:
	if player:
		player.global_position = current_checkpoint
		print("Teleported to checkpoint at:", current_checkpoint)
