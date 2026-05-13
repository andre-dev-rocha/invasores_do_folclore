extends Area2D

@export_group("Comportamento do Míssil")
@export var velocidade_inicial: float = 50.0
@export var velocidade_maxima: float = 800.0
@export var tempo_para_acelerar: float = 3.0 # Segundos até atingir a vel. máxima
@export var taxa_curva: float = 0.7    
@export var tempo_vida: float = 3.0    

var player = null
var direcao_atual: Vector2 = Vector2.DOWN 
var tempo_vivo: float = 0.0
var velocidade_atual: float = 0.0

func _ready():
	# Começa com a velocidade baixa
	velocidade_atual = velocidade_inicial
	
	player = get_tree().get_first_node_in_group("player")
	if player is Area2D:
		player = player.get_parent()
	
	get_tree().create_timer(tempo_vida).timeout.connect(queue_free)
	
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _process(delta):
	# 1. Lógica de Aceleração Progressiva
	tempo_vivo += delta
	# Calcula o progresso de 0.0 a 1.0 baseado no tempo definido
	var progresso_acel = clamp(tempo_vivo / tempo_para_acelerar, 0.0, 1.0)
	# Faz a transição suave entre a velocidade inicial e a máxima
	velocidade_atual = lerp(velocidade_inicial, velocidade_maxima, progresso_acel)
	
	# 2. Movimento Teleguiado
	if player and is_instance_valid(player):
		var direcao_alvo = (player.global_position - global_position).normalized()
		direcao_atual = direcao_atual.slerp(direcao_alvo, taxa_curva * delta).normalized()
	
	# 3. Aplica o movimento usando a velocidade atual (que está aumentando)
	position += direcao_atual * velocidade_atual * delta
	
	# 4. Rotação do Sprite
	rotation = direcao_atual.angle() + (PI / 2) 

func _on_area_entered(area):
	if area.is_in_group("player") or area.get_parent().is_in_group("player") or area.is_in_group("escudo"):
		var alvo = area
		if not alvo.has_method("receber_dano") and alvo.get_parent().has_method("receber_dano"):
			alvo = alvo.get_parent()
		
		if alvo.has_method("receber_dano"):
			alvo.receber_dano()
		
		queue_free()
