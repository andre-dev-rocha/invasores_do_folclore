extends ParallaxBackground

# Velocidade da rolagem do cenário (pixels por segundo)
@export var scroll_speed: float = 50.0

func _process(delta: float) -> void:
	# Move o cenário continuamente para cima (o que faz as estrelas descerem)
	scroll_offset.y += scroll_speed * delta
