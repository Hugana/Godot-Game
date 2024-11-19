extends Label

func _process(delta: float) -> void:
	#Fazer a label desaparecer quando o jogador pressiona "A" ou "D"
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
		pass
		
		
