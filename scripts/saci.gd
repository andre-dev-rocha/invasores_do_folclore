extends Area2D

# Configurações de Movimento (GDD 2.1 - Saci)
@export_group("Movimento Infinito")
@export var valor_pontos: int = 100 # Cada Saci vale 100 pontos
@export var velocidade_descida: float = 100.0  # Velocidade geral para baixo
@export var amplitude_horizontal: float = 90.0 # Largura do símbolo infinito
@export var amplitude_vertical_laco: float = 60.0 # Altura dos laços do "8"
@export var frequencia: float = 2.5   # Velocidade da execução do desenho

var tempo_decorrido: float = 0.0
var x_inicial: float = 0.0
var y_base: float = 0.0 # Ponto de referência para a descida

# Referência para o tiro 
var cena_pipoca = preload("res://scenes/entities/pipoca_magica.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_ponto = preload("res://scenes/entities/ponto_flutuante.tscn")
func _ready():
	x_inicial = global_position.x
	y_base = global_position.y
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	# Conecta o timer de tiro
	$TimerTiro.timeout.connect(atirar_pipoca)

func _process(delta):
	tempo_decorrido += delta
	
	# 1. Calcula a descida base constante
	y_base += velocidade_descida * delta
	
	# 2. Calcula a oscilação do símbolo do infinito (Lemniscata de Gerono)
	var t = tempo_decorrido * frequencia
	
	# Movimento Horizontal (Vai e volta)
	var oscilacao_x = sin(t) * amplitude_horizontal
	
	# Movimento Vertical Local (Sobe e desça duas vezes por ciclo)
	# Usamos sin(t) * cos(t) para criar o formato do laço
	var oscilacao_y_local = (sin(t) * cos(t)) * amplitude_vertical_laco
	
	
	# 3. Aplica as posições finais
	global_position.x = x_inicial + oscilacao_x
	global_position.y = y_base + oscilacao_y_local

func atirar_pipoca():
	# 1. Cria uma instância da pipoca
	var pipoca = cena_pipoca.instantiate()
	
	# 2. Define a posição inicial (onde o Saci está agora)
	pipoca.global_position = global_position
	
	# 3. Adiciona a pipoca à cena principal (para ela não seguir o movimento do Saci)
	get_tree().current_scene.add_child(pipoca)
	
	print("Saci lançou uma pipoca mágica!")
	
func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		# 1. Cria a explosão 
		var explosao = cena_explosao.instantiate()
		explosao.global_position = global_position
		get_tree().current_scene.add_child(explosao)
		
	
		var ponto = cena_ponto.instantiate()
		
		ponto.global_position = global_position
		
		get_tree().current_scene.add_child(ponto)
		# ===========================
		
		# 3. Adiciona pontos 
		if get_tree().current_scene.has_method("adicionar_pontos"):
			get_tree().current_scene.adicionar_pontos(valor_pontos)
		
		# 4. Limpeza 
		area.queue_free()
		queue_free()
