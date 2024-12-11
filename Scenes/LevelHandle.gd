extends Node2D

@export var checkpoint_1: Area2D
@export var checkpoint_2: Area2D

@export var player: CharacterBody2D

var is_in_checkpoint_1 = false
var is_in_checkpoint_2 = false

var position_checkpoint: Vector2 = Vector2.ZERO 


func _process(delta: float) -> void:
	if checkpoint_1:
		for body in checkpoint_1.get_overlapping_bodies():
			if body == player:
				is_in_checkpoint_1 = true
				position_checkpoint = checkpoint_1.global_position 

	if checkpoint_2:
		for body in checkpoint_2.get_overlapping_bodies():
			if body == player:
				is_in_checkpoint_2 = true
				position_checkpoint = checkpoint_2.global_position  

	
	if Input.is_action_just_pressed("checkpoint"):
		if position_checkpoint != Vector2.ZERO:
			teleport_to_checkpoint()


func teleport_to_checkpoint() -> void:
	if player:
		player.global_position = position_checkpoint
		print("Teleported to checkpoint at:", position_checkpoint)
