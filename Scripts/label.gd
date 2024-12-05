extends Label

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var entered = false
var pressed = false

var appeared = false

@export var input1 = ""
@export var input2 = ""



@onready var area_2d: Area2D = $Area2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == 'Player':
		if !entered:
			entered = true
			_fade_in(self)


# Fazer a label desaparecer quando o jogador pressiona "A" ou "D"
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed(input1) or Input.is_action_just_pressed(input2)) and appeared and not pressed:
		print("text fading out...")
		pressed = true
		_fade_out(self)

# Fazer a animação de esconder o texto
func _fade_out(body):
	animation_player.play("hide")
	

func _fade_in(body):
	animation_player.play("show")
	appeared = true
