extends Area2D

signal derrotado
signal hp_alterado(hp_atual, hp_maximo)
# Áudios dos disparos do Bicho papão:
@onready var som_laser_carregando = $SomLaserCarregando
@onready var som_laser_tiro = $SomLaserTiro
@onready var som_caveira = $SomCaveira
@onready var som_fogo_mula = $SomFogoMula
@onready var som_granada = $SomGranada

@export_group("Atributos do Chefe")
@export var hp_maximo: float = 8000.0
@export var valor_pontos: int = 50000

@export_group("Ciclo de Habilidades")
@export var tempo_entre_habilidades: float = 1.5

@export_group("1. Laser")
@export var velocidade_rotacao_raio: float = 1.5
@export var duracao_laser: float = 3.5
@export var intervalo_dano_laser: float = 1.0

@export_group("2. Chuva de Caveiras")
@export var quantidade_caveiras: int = 14
@onready var pontos_de_disparo = $PontosDeDisparo

@export_group("3. Bombardeio Lateral")
@export var duracao_bombardeio: float = 12.0
@export var velocidade_movimento: float = 200.0
@export var cadencia_fogo_mula: float = 1.5
@export var cadencia_granada: float = 3.0

enum Estado { SURGINDO, IDLE, RAIO_PESADELO, CAVEIRAS, BOMBARDEIO, MORTO }

# Nova sequência de habilidades
const SEQUENCIA_HABILIDADES = [
	Estado.RAIO_PESADELO,
	Estado.CAVEIRAS,
	Estado.BOMBARDEIO
]

var hp_atual: float
var estado_atual: int = Estado.SURGINDO
var indice_habilidade: int = 0
var jogador_ref: Node2D = null
var morreu: bool = false
var tempo_para_dano_laser: float = 0.0

# Variáveis para o Bombardeio
var direcao_movimento: int = 1
var tempo_prox_fogo: float = 0.0
var tempo_prox_granada: float = 0.0

@onready var sprite = $Sprite2D
@onready var laser_area = $LaserArea
@onready var timer_habilidade = $TimerHabilidade

# --- CARREGUE AS CENAS AQUI (Verifique os caminhos!) ---
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_caveira = preload("res://scenes/entities/caveira_teleguiada.tscn")
var cena_bola_energia = preload("res://scenes/entities/bola_energia.tscn")
var cena_fogo_mula = preload("res://scenes/entities/fogo_mula.tscn") # Ajuste o nome da cena do tiro da mula

func _ready():
	hp_atual = hp_maximo
	_atualizar_jogador_ref()
	_configurar_colisoes()
	_conectar_sinais()
	
	_iniciar_combate()

func _process(delta):
	if morreu:
		return

	match estado_atual:
		Estado.RAIO_PESADELO:
			_executar_raio_pesadelo(delta)
		Estado.BOMBARDEIO:
			_executar_bombardeio(delta)

func _configurar_colisoes():
	collision_layer = 2
	collision_mask = 9
	monitoring = true
	monitorable = true

	laser_area.visible = false
	laser_area.collision_layer = 0
	laser_area.collision_mask = 1
	laser_area.monitorable = false
	laser_area.monitoring = false

func _conectar_sinais():
	var timer_callable = Callable(self, "_on_timer_habilidade_timeout")
	if not timer_habilidade.timeout.is_connected(timer_callable):
		timer_habilidade.timeout.connect(timer_callable)

	var dano_callable = Callable(self, "_on_area_entered")
	if not area_entered.is_connected(dano_callable):
		area_entered.connect(dano_callable)

	var laser_callable = Callable(self, "_on_laser_area_entered")
	if not laser_area.area_entered.is_connected(laser_callable):
		laser_area.area_entered.connect(laser_callable)

func _iniciar_combate():
	if morreu or not is_inside_tree():
		return
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _agendar_proxima_habilidade(tempo: float):
	timer_habilidade.stop()
	timer_habilidade.start(tempo)

func _on_timer_habilidade_timeout():
	if morreu or not is_inside_tree():
		return

	match estado_atual:
		Estado.IDLE:
			_escolher_proxima_habilidade()
		Estado.RAIO_PESADELO:
			_encerrar_raio_pesadelo()
		Estado.CAVEIRAS:
			_encerrar_caveiras()
		Estado.BOMBARDEIO:
			_encerrar_bombardeio()

func _escolher_proxima_habilidade():
	var habilidade = SEQUENCIA_HABILIDADES[indice_habilidade]
	indice_habilidade = (indice_habilidade + 1) % SEQUENCIA_HABILIDADES.size()

	match habilidade:
		Estado.RAIO_PESADELO:
			_preparar_raio_pesadelo()
		Estado.CAVEIRAS:
			_iniciar_chuva_caveiras()
		Estado.BOMBARDEIO:
			_iniciar_bombardeio()

# --- 1. RAIO DO PESADELO ---
func _preparar_raio_pesadelo():
	estado_atual = Estado.RAIO_PESADELO
	tempo_para_dano_laser = 0.0

	var centro_tela = Vector2(get_viewport_rect().size.x / 2.0, 180.0)
	var tween = create_tween()
	
	# 1. O chefe leva 1.2 segundos para ir até o centro da tela
	tween.tween_property(self, "global_position", centro_tela, 1.2).set_trans(Tween.TRANS_QUAD)
	
	# 2. Assim que ele chega no centro, ele fica vermelho e o som de carregamento começa
	tween.tween_callback(func(): 
		modulate = Color(3.0, 0.5, 0.5)
		if som_laser_carregando: som_laser_carregando.play()
	)
	
	# 3. O jogo ESPERA exatamente 2.4 segundos (o tempo do seu áudio de carregamento)
	tween.tween_interval(2.4) # <-- Alterado para sincronizar com o áudio
	
	# 4. Assim que os 2.4 segundos passam, a função de atirar o laser é chamada
	tween.tween_callback(_ativar_laser)
func _ativar_laser():
	if morreu or not is_inside_tree(): return
	modulate = Color(1.0, 1.0, 1.0)
	laser_area.visible = true
	laser_area.set_deferred("monitoring", true)
	
	# Toca o som do tiro contínuo
	if som_laser_tiro: som_laser_tiro.play()
	
	_agendar_proxima_habilidade(duracao_laser)
func _executar_raio_pesadelo(delta):
	_atualizar_jogador_ref()
	if is_instance_valid(jogador_ref):
		var direcao = global_position.direction_to(jogador_ref.global_position)
		var angulo_alvo = direcao.angle() - PI / 2.0
		rotation = lerp_angle(rotation, angulo_alvo, velocidade_rotacao_raio * delta)

	if not laser_area.monitoring: return

	tempo_para_dano_laser -= delta
	if tempo_para_dano_laser > 0.0: return

	for area in laser_area.get_overlapping_areas():
		if _causar_dano_no_jogador(area):
			tempo_para_dano_laser = intervalo_dano_laser
			break

func _encerrar_raio_pesadelo():
	laser_area.visible = false
	laser_area.set_deferred("monitoring", false)
	
	# Para o som do laser quando ele desliga
	if som_laser_tiro: som_laser_tiro.stop()
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", 0.0, 0.8)
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

# --- 2. CAVEIRAS ---
func _iniciar_chuva_caveiras():
	estado_atual = Estado.CAVEIRAS
	var marcadores = pontos_de_disparo.get_children()
				# Toca o som cada vez que uma caveira é disparada
	if som_caveira: som_caveira.play()
	if marcadores.size() > 0:
		for i in range(quantidade_caveiras):
			if hp_atual <= 0: break
			await get_tree().create_timer(0.3).timeout 
			
			var caveira = cena_caveira.instantiate()
			var marcador_escolhido = marcadores.pick_random()
			caveira.global_position = marcador_escolhido.global_position
			caveira.rotation = deg_to_rad(90) 
			
			get_parent().add_child(caveira)
			
			
	_agendar_proxima_habilidade(1.0)
	_agendar_proxima_habilidade(1.0)

func _encerrar_caveiras():
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)


# --- 3. BOMBARDEIO LATERAL (Novo!) ---
func _iniciar_bombardeio():
	estado_atual = Estado.BOMBARDEIO
	tempo_prox_fogo = cadencia_fogo_mula
	tempo_prox_granada = cadencia_granada
	
	# Garante que o chefe volte a ficar reto antes de começar a se mover
	var tween = create_tween()
	tween.tween_property(self, "rotation", 0.0, 0.5)
	
	_agendar_proxima_habilidade(duracao_bombardeio)

func _executar_bombardeio(delta):
	# Movimento Esquerda/Direita
	global_position.x += velocidade_movimento * direcao_movimento * delta
	
	var margem = 80.0
	var limite_tela = get_viewport_rect().size.x
	
	if global_position.x > limite_tela - margem:
		direcao_movimento = -1
	elif global_position.x < margem:
		direcao_movimento = 1

	# Lógica de disparos
	tempo_prox_fogo -= delta
	if tempo_prox_fogo <= 0:
		_disparar_fogo_mula()
		tempo_prox_fogo = cadencia_fogo_mula
		
	tempo_prox_granada -= delta
	if tempo_prox_granada <= 0:
		_disparar_granada()
		tempo_prox_granada = cadencia_granada

func _disparar_fogo_mula():
	# Define as três direções usando vetores idênticos aos da Mula
	var direcoes = [
		Vector2.DOWN,                  # Reto para baixo
		Vector2(-1, 1).normalized(),   # Diagonal Esquerda
		Vector2(1, 1).normalized()     # Diagonal Direita
	]

	for dir in direcoes:
		var fogo = cena_fogo_mula.instantiate()
		
		fogo.scale = Vector2(0.08, 0.08)
		var offset_x = dir.x * 50.0
		fogo.global_position = global_position + Vector2(offset_x, 50)
		
		fogo.modulate = Color(1.0, 0.4, 0.0, 1.0) 
		
		fogo.direcao_movimento = dir
		
		fogo.rotation = dir.angle() + PI/2 
			
		get_parent().add_child(fogo)

	if som_fogo_mula:
		som_fogo_mula.play()

func _disparar_granada():
	var bola = cena_bola_energia.instantiate()
	bola.global_position = global_position + Vector2(0, 40)
	bola.modulate = Color(1.0, 1.0, 1.0, 1.0)
	get_parent().add_child(bola)
	
	# Toca o som da granada da Cuca
	if som_granada: som_granada.play()

func _encerrar_bombardeio():
	estado_atual = Estado.IDLE
	
	# Traz o chefe de volta para o centro suavemente
	var centro_x = get_viewport_rect().size.x / 2.0
	var tween = create_tween()
	tween.tween_property(self, "global_position:x", centro_x, 1.0).set_trans(Tween.TRANS_QUAD)
	
	_agendar_proxima_habilidade(tempo_entre_habilidades)


# --- SISTEMA DE DANO E COLISÃO ---
func _on_area_entered(area):
	if morreu: return
	if area.is_in_group("laser_player"):
		_receber_dano(25.0) # Assumindo 25 de dano por tiro
		area.queue_free()

func _receber_dano(dano: float):
	if morreu: return
	hp_atual -= dano

	hp_alterado.emit(hp_atual)
	
	if hp_atual <= 0.0:
		_morrer()
		return

	var cor_original = modulate
	modulate = Color(10.0, 10.0, 10.0)
	await get_tree().create_timer(0.05).timeout
	if not morreu and is_inside_tree():
		modulate = cor_original

func _morrer():
	if morreu: return
	morreu = true
	estado_atual = Estado.MORTO
	timer_habilidade.stop()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	laser_area.visible = false
	laser_area.set_deferred("monitoring", false)

	if is_inside_tree():
		var cena_atual = get_tree().current_scene
		if cena_atual and cena_atual.has_method("adicionar_pontos"):
			cena_atual.adicionar_pontos(valor_pontos)

	var parent = get_parent()
	if parent:
		var explosao = cena_explosao.instantiate()
		explosao.global_position = global_position
		explosao.scale = Vector2(4.0, 4.0)
		parent.call_deferred("add_child", explosao)

	derrotado.emit()
	queue_free()

func _on_laser_area_entered(area):
	if estado_atual == Estado.RAIO_PESADELO:
		_causar_dano_no_jogador(area)

func _causar_dano_no_jogador(area) -> bool:
	var jogador = _obter_jogador_por_area(area)
	if jogador == null:
		return false
	
	# Usando a versão sem argumentos como você corrigiu!
	jogador.receber_dano() 
	return true

func _obter_jogador_por_area(area) -> Node:
	if area.has_method("receber_dano"):
		return area
	var parent = area.get_parent()
	if parent and parent.has_method("receber_dano"):
		return parent
	return null

func _atualizar_jogador_ref():
	if not is_inside_tree(): return
	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D and node.has_method("receber_dano"):
			jogador_ref = node
			return
		if node is Area2D:
			var parent = node.get_parent()
			if parent is Node2D and parent.has_method("receber_dano"):
				jogador_ref = parent
				return
	jogador_ref = null
