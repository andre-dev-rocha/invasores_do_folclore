extends ParallaxBackground

@export var velocidade_estrelas = 50.0 
@export var velocidade_sombras = 150.0

func _process(delta):
	# Move as estrelas para baixo (eixo Y)
	scroll_offset.y += velocidade_estrelas * delta
	
	# Move as sombras para o lado (eixo X)
	scroll_offset.x += velocidade_sombras * delta
