extends AnimatedSprite2D

# Configurações da Órbita
@export var centro_orbita: Vector2 = Vector2(1152, 0) 
@export var raio_x: float = 1050 # Distância horizontal até o canto esquerdo
@export var raio_y: float = 600.0 # Distância vertical até o centro-direito
@export var velocidade: float = 0.007 # Velocidade do movimento


var angulo: float = PI 

func _ready():
	play("default") 
	atualizar_posicao()

func _process(delta: float):

	if angulo > PI/2:
		angulo -= velocidade * delta
		atualizar_posicao()

func atualizar_posicao():
	var nova_pos = Vector2(
		centro_orbita.x + cos(angulo) * raio_x,
		centro_orbita.y + sin(angulo) * raio_y
	)
	global_position = nova_pos
