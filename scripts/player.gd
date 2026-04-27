extends CharacterBody2D

@export var velocidade : float = 400.0
@onready var som_motor = $SomMotor

# Configurações de volume em Decibéis
var volume_idle: float = -15.0  # Som baixo (parado)
var volume_movimento: float = -5.0 # Som alto (andando)
var suavidade_volume: float = 5.0 # Velocidade da transição

var tempo_inicio_cooldown = 0.0
var vidas = 3

# Configurações do Escudo (Modificadas para 4s e 16s) 
@export var duracao_escudo : float = 7.0      
@export var tempo_cooldown_escudo : float = 28.0 

var escudo_disponivel = true
var escudo_ativo = false

@onready var som_escudo = $SomEscudo
@onready var escudo_area = $EscudoArea
@onready var ponto_disparo = $PontoDisparo
@onready var anim_escudo = $EscudoArea/AnimatedSprite2D
@onready var hud = get_tree().current_scene.find_child("HUD")
@onready var som_foguete = $SomFoguete
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_laser = preload("res://scenes/entities/foguete.tscn")
func _process(_delta):
	atualizar_hud_escudo()


func atualizar_hud_escudo():
	if hud == null: return
	
	if escudo_ativo:
		# Enquanto o escudo está protegendo por 4s, a barra fica cheia
		hud.atualizar_barra_escudo(100)
	elif not escudo_disponivel:
		# Calcula o progresso dos 16 segundos de cooldown 
		var tempo_passado = (Time.get_ticks_msec() - tempo_inicio_cooldown) / 1000.0
		var porcentagem = (tempo_passado / tempo_cooldown_escudo) * 100
		hud.atualizar_barra_escudo(clamp(porcentagem, 0, 100))
	else:
		# Escudo pronto para uso
		hud.atualizar_barra_escudo(100)
		
		

func _physics_process(_delta):
	# 1. Movimentação Horizontal e Vertical
	# Input.get_vector lê as 4 direções e retorna um vetor normalizado
	var direcao = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direcao != Vector2.ZERO:
		velocity = direcao * velocidade
		# Aumenta o volume suavemente se estiver movendo
		som_motor.volume_db = lerp(som_motor.volume_db, volume_movimento, suavidade_volume * _delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocidade)
		# Diminui o volume suavemente se estiver parado
		som_motor.volume_db = lerp(som_motor.volume_db, volume_idle, suavidade_volume * _delta)
	
	move_and_slide()
	
	# 2. Limitar a nave dentro da tela (Clamp)
	# Isso evita que o jogador suma por cima ou por baixo
	var limite_tela = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 30, limite_tela.x - 30)
	global_position.y = clamp(global_position.y, 30, limite_tela.y - 30)
	
	
	# Controle de Tiro 
	if Input.is_action_just_pressed("atirar"):
		atirar()
		
	
	if Input.is_action_just_pressed("escudo") and escudo_disponivel:
		iniciar_ciclo_escudo()


func iniciar_ciclo_escudo():
	escudo_ativo = true
	escudo_disponivel = false 
	escudo_area.visible = true
	escudo_area.set_deferred("monitoring", true)
	
	
# === NOVA LÓGICA DE ÁUDIO ===
	if som_escudo:
		som_escudo.play() # Inicia o som do escudo
	# ============================
	
	anim_escudo.frame = 0 
	anim_escudo.play("default") 
	
	print("Escudo Ativado! Proteção por ", duracao_escudo, " segundos.")

	# Espera o tempo de duração do escudo (7 segundos)
	await get_tree().create_timer(duracao_escudo).timeout
	
	escudo_ativo = false
	escudo_area.visible = false
	escudo_area.set_deferred("monitoring", false)
	
	# === PARAR O ÁUDIO (Opcional) ===
	if som_escudo:
		som_escudo.stop() # Para o som quando o escudo desativa
	# ===============================
	
	anim_escudo.stop() 
	
	print("Escudo desativado. Iniciando cooldown...")
	tempo_inicio_cooldown = Time.get_ticks_msec()
	
	await get_tree().create_timer(tempo_cooldown_escudo).timeout
	escudo_disponivel = true

func atirar():
	print("Laser disparado pelo Capitão Zé Galáxia!")
	var laser = cena_laser.instantiate()
	laser.z_index = 10 
	laser.global_position = ponto_disparo.global_position
	get_tree().current_scene.add_child(laser)
	
	som_foguete.play()

func receber_dano():
	if escudo_ativo:
		
		return

	vidas -= 1
	print("Dano recebido! Vidas: ", vidas)
	
	if hud:
		hud.atualizar_vidas(vidas)
	
	if vidas <= 0:
		morrer()

func morrer():
	print("Capitão Zé Galáxia foi abatido!")
	$Hitbox.set_deferred("disabled", true)
	# 1. Cria a explosão no lugar da nave
	var explosao = cena_explosao.instantiate()
	explosao.global_position = global_position
	get_tree().current_scene.add_child(explosao)
	
	# 2. Esconde o jogador e desativa colisão (ele "sumiu")
	visible = false
	set_physics_process(false) # Para o movimento e motor
	# Desativa a colisão para não tomar dano depois de morto
	$Hitbox.set_deferred("disabled", true) 
	
	# 3. Avisa a fase para iniciar a sequência de Game Over
	if get_tree().current_scene.has_method("iniciar_game_over"):
		get_tree().current_scene.iniciar_game_over()
func limitar_na_tela():
	var largura_tela = get_viewport_rect().size.x
	global_position.x = clamp(global_position.x, 20, largura_tela - 20) 
