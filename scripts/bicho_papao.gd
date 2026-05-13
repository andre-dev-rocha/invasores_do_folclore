extends Area2D

@export_group("Atributos do Chefe")
@export var hp_maximo: float = 5000.0
var hp_atual: float
@export var valor_pontos: int = 10000

@export_group("Raio do Pesadelo")
@export var velocidade_rotacao_raio: float = 1.5
@export var dano_raio: int = 2

@export_group("Atração do Abismo")
@export var forca_atracao: float = 150.0

# Máquina de Estados
enum Estado { SURGINDO, IDLE, RAIO_PESADELO, BREU_ABSOLUTO, CAVEIRAS, ATRACAO }
var estado_atual: int = Estado.SURGINDO

var usou_breu: bool = false
var jogador_ref: Node2D = null

# Referências de Nós Internos
@onready var sprite = $Sprite2D
@onready var laser_area = $LaserArea # Um Area2D comprido e retangular para o raio
@onready var laser_visual = $LaserArea/ColorRect # O visual do laser
@onready var timer_habilidade = $TimerHabilidade
@onready var canvas_modulate = get_node_or_null("/root/Main/CanvasModulate") # Ajuste o caminho da sua fase

# Cenas
var cena_caveira = preload("res://scenes/entities/caveira_teleguiada.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

func _ready():
	hp_atual = hp_maximo
	jogador_ref = get_tree().get_first_node_in_group("player")
	
	laser_area.visible = false
	laser_area.monitoring = false
	
	# O chefe surge do topo da tela e depois vai para o IDLE
	var tween = create_tween()
	tween.tween_property(self, "global_position:y", 150.0, 3.0).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_iniciar_combate)

func _iniciar_combate():
	estado_atual = Estado.IDLE
	timer_habilidade.timeout.connect(_escolher_proxima_habilidade)
	timer_habilidade.start(2.0)

func _process(delta):
	if hp_atual <= 0: return
	
	match estado_atual:
		Estado.RAIO_PESADELO:
			_executar_raio_pesadelo(delta)
		Estado.BREU_ABSOLUTO:
			_executar_cura_breu(delta)
		Estado.ATRACAO:
			_executar_atracao(delta)

# --- SISTEMA DE ESTADOS (HABILIDADES) ---

func _escolher_proxima_habilidade():
	# Verifica se deve usar o Breu Absoluto (Vida <= 50% e nunca usou)
	if hp_atual <= hp_maximo * 0.5 and not usou_breu:
		_iniciar_breu_absoluto()
		return
		
	# Sorteia as outras habilidades
	var roleta = randi() % 3
	match roleta:
		0: _preparar_raio_pesadelo()
		1: _iniciar_chuva_caveiras()
		2: _iniciar_atracao()

# 1. RAIO DO PESADELO
func _preparar_raio_pesadelo():
	estado_atual = Estado.IDLE # Pausa enquanto se move
	
	var centro_tela = Vector2(get_viewport_rect().size.x / 2.0, 150)
	var tween = create_tween()
	# Move pro centro
	tween.tween_property(self, "global_position", centro_tela, 1.5).set_trans(Tween.TRANS_QUAD)
	
	# Delay/Telegraph (Boca brilhando)
	tween.tween_callback(func(): modulate = Color(3.0, 1.0, 1.0)) # Fica vermelho vivo
	tween.tween_interval(1.5)
	
	# Dispara
	tween.tween_callback(func():
		modulate = Color(1.0, 1.0, 1.0)
		laser_area.visible = true
		laser_area.monitoring = true
		estado_atual = Estado.RAIO_PESADELO
		timer_habilidade.start(4.0) # Duração do raio
	)

func _executar_raio_pesadelo(delta):
	if is_instance_valid(jogador_ref):
		# Gira suavemente na direção do jogador enquanto atira
		var direcao = global_position.direction_to(jogador_ref.global_position)
		var angulo_alvo = direcao.angle() - PI/2 # Ajuste de -PI/2 dependendo da orientação do seu sprite
		rotation = lerp_angle(rotation, angulo_alvo, velocidade_rotacao_raio * delta)

# 2. BREU ABSOLUTO (Cura)
func _iniciar_breu_absoluto():
	estado_atual = Estado.BREU_ABSOLUTO
	usou_breu = true
	
	if canvas_modulate:
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(0.05, 0.05, 0.05, 1.0), 2.0)
	
	# Fica no escuro por 8 segundos
	timer_habilidade.start(8.0)

func _executar_cura_breu(delta):
	# Cura 5% do HP máximo por segundo no escuro
	if hp_atual < hp_maximo:
		hp_atual += (hp_maximo * 0.05) * delta
		hp_atual = min(hp_atual, hp_maximo)

# Quando o tempo do breu acabar, o timer_habilidade chama essa função indiretamente via _escolher_proxima_habilidade,
# então precisamos garantir que a luz volte:
func _encerrar_breu():
	if canvas_modulate:
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(1, 1, 1, 1), 2.0)

# 3. CHUVA DE CAVEIRAS
func _iniciar_chuva_caveiras():
	estado_atual = Estado.CAVEIRAS
	# Dispara 5 caveiras em sequência
	for i in range(5):
		await get_tree().create_timer(0.4).timeout
		var caveira = cena_caveira.instantiate()
		caveira.global_position = global_position + Vector2(randf_range(-50, 50), 50)
		get_parent().add_child(caveira)
	
	timer_habilidade.start(1.0) # Passa para a próxima habilidade rápido

# 4. ATRAÇÃO DO ABISMO
func _iniciar_atracao():
	estado_atual = Estado.ATRACAO
	# Animação de abrir a boca/asas aqui
	timer_habilidade.start(5.0) # Puxa o jogador por 5 segundos

func _executar_atracao(delta):
	if is_instance_valid(jogador_ref):
		# Puxa o jogador fisicamente na direção do chefe
		var direcao_puxao = jogador_ref.global_position.direction_to(global_position)
		jogador_ref.global_position += direcao_puxao * forca_atracao * delta

# --- ROTINAS DE DANO E MORTE ---
func receber_dano(dano: float):
	hp_atual -= dano
	# Flash de dano
	modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if hp_atual <= 0:
		_morrer()

func _morrer():
	estado_atual = Estado.SURGINDO # Trava a IA
	_encerrar_breu()
	laser_area.queue_free()
	
	var explosao = cena_explosao.instantiate()
	explosao.global_position = global_position
	explosao.scale = Vector2(3.0, 3.0)
	get_parent().add_child(explosao)
	
	queue_free()

func _on_timer_habilidade_timeout():
	# Reseta estados que precisam de limpeza
	if estado_atual == Estado.RAIO_PESADELO:
		laser_area.visible = false
		laser_area.monitoring = false
		
		# Volta a rotação pro padrão suavemente
		var tween = create_tween()
		tween.tween_property(self, "rotation", 0.0, 1.0)
		
	if estado_atual == Estado.BREU_ABSOLUTO:
		_encerrar_breu()
		
	_escolher_proxima_habilidade()
