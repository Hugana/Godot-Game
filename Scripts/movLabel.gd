extends Label

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var pressed = false

# Fazer a label desaparecer quando o jogador pressiona "A" ou "D"
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right")) and not pressed:
		print("text fading out...")
		pressed = true
		_fade_out(self)

# Fazer a animação de esconder o texto
func _fade_out(body):
	animation_player.play("hide")
