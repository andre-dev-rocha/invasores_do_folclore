extends Area2D

@export_group("Movimento Teleguiado")
@export var velocidade_inicial: float = 100.0
@export var velocidade_maxima: float = 850
@export var aceleracao: float = 150.0 # O quão rápido ela atinge a velocidade máxima
@export var velocidade_curva: float = 1.5 # Valor baixo = curva difícil/lenta

var velocidade_atual: float
var jogador_ref: CharacterBody2D

func _ready():
	velocidade_atual = velocidade_inicial
	jogador_ref = get_tree().get_first_node_in_group("player")
	
	# Destrói a caveira após 8 segundos se ela não acertar nada
	await get_tree().create_timer(8.0).timeout
	queue_free()

func _process(delta):
	# 1. Aceleração: Aumenta a velocidade atual até o limite máximo
	velocidade_atual = move_toward(velocidade_atual, velocidade_maxima, aceleracao * delta)
	
	# 2. Rotação: Gira suavemente em direção ao Zé Galáxia
	if is_instance_valid(jogador_ref):
		var direcao_alvo = global_position.direction_to(jogador_ref.global_position)
		var angulo_desejado = direcao_alvo.angle()
		
		rotation = lerp_angle(rotation, angulo_desejado, velocidade_curva * delta)
		
	# 3. Movimentação: Move para a direção em que está olhando com a velocidade atualizada
	var direcao_frente = Vector2.RIGHT.rotated(rotation)
	global_position += direcao_frente * velocidade_atual * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("receber_dano"):
			body.receber_dano() # Causa 1 de dano no jogador
		
		# Adicione uma explosão aqui se desejar, antes do queue_free
		queue_free()
