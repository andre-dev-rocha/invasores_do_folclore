extends CharacterBody2D

# Variável exportada aparece no Inspector, permitindo ajustar a velocidade sem abrir o código
@export var speed: float = 200.0

# Variável para guardar o tamanho da tela
var screen_size: Vector2

func _ready() -> void:
	# Quando o jogo começa, pegamos o tamanho da tela (320x240, conforme seu projeto)
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	# 1. Obter a direção (Input)
	# get_axis retorna -1 se pressionar esquerda, 1 se pressionar direita, e 0 se nenhum.
	# Lembre-se de ter configurado "mover_esquerda" e "mover_direita" no Input Map!
	var direction := Input.get_axis("mover_esquerda", "mover_direita")
	
	# 2. Aplicar a velocidade horizontal
	velocity.x = direction * speed
	velocity.y = 0 # Sem gravidade, garantindo que não suba nem desça
	
	# 3. Mover a nave
	move_and_slide()
	
	# 4. Limitar a posição da nave para não sair da tela
	global_position.x = clamp(global_position.x, 0, screen_size.x)
