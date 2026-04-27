extends Area2D

@export_group("Configurações da Granada")
@export var tempo_detonacao: float = 4.0
@export var raio_atracao: float = 400.0     # Distância de detecção
@export var forca_atracao: float = 100.0      # Velocidade de perseguição
@export var velocidade_descida_base: float = 80.0

var tempo_vida: float = 0.0
var player = null
var explodiu: bool = false

# Cores para a transição (Rosa Neon para Vermelho Alerta)
var cor_rosa = Color(1.0, 1.0, 1)
var cor_vermelha = Color(1.0, 0.0, 0.0)

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

func _ready():
	# Busca o player pelo grupo (garanta que o Player esteja no grupo "player")
	player = get_tree().get_first_node_in_group("player")
	
	# Inicia a animação de pulsar/vibrar
	if anim.has_animation("pre_explosao"):
		anim.play("pre_explosao")

func _process(delta):
	if explodiu: return
	
	tempo_vida += delta
	var progresso = tempo_vida / tempo_detonacao # Vai de 0.0 a 1.0
	
	# 1. ANIMAÇÃO DE COR (Lerp suave entre Rosa e Vermelho)
	sprite.modulate = cor_rosa.lerp(cor_vermelha, progresso)
	
	# 2. VELOCIDADE DA ANIMAÇÃO (Fica mais frenética com o tempo)
	# Começa em 1x e termina em 4x a velocidade original
	anim.speed_scale = 1.0 + (progresso * 3.0)
	
	# 3. LÓGICA DE ATRAÇÃO E MOVIMENTO
	if player:
		var distancia = global_position.distance_to(player.global_position)
		
		if distancia < raio_atracao:
			# Segue o jogador (Atração Hipnótica)
			var direcao = (player.global_position - global_position).normalized()
			global_position += direcao * forca_atracao * delta
		else:
			# Movimento padrão de descida
			global_position.y += velocidade_descida_base * delta
	
	# 4. VERIFICA DETONAÇÃO
	if tempo_vida >= tempo_detonacao:
		detonar()

func detonar():
	if explodiu: return
	explodiu = true
	
	# Instancia a explosão
	var explosion = cena_explosao.instantiate()
	explosion.global_position = global_position
	explosion.scale = Vector2(2.5, 2.5) # Granada é mais potente que tiro comum
	get_tree().current_scene.add_child(explosion)
	
	# Lógica de dano por proximidade na explosão
	if player:
		var distancia_final = global_position.distance_to(player.global_position)
		if distancia_final < 120: # Raio do dano da explosão
			if player.has_method("receber_dano"):
				player.receber_dano()
			
	queue_free()

func _on_area_entered(area):
	# Detonação imediata ao colidir com o corpo do player ou o escudo ativo
	if area.is_in_group("player") or area.is_in_group("escudo"):
		detonar()
