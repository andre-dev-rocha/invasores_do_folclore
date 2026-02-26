extends CharacterBody2D

@export var velocidade : float = 400.0
var tempo_inicio_cooldown = 0.0
var vidas = 3

# Configurações do Escudo (Modificadas para 4s e 16s) 
@export var duracao_escudo : float = 4.0      
@export var tempo_cooldown_escudo : float = 16.0 

var escudo_disponivel = true
var escudo_ativo = false

@onready var escudo_area = $EscudoArea
@onready var ponto_disparo = $PontoDisparo
@onready var anim_escudo = $EscudoArea/AnimatedSprite2D
@onready var hud = get_tree().current_scene.find_child("HUD")
@onready var som_foguete = $SomFoguete

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
	
	var direcao = Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * velocidade if direcao else move_toward(velocity.x, 0, velocidade)
	move_and_slide()
	limitar_na_tela()
	
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
	
	
	anim_escudo.frame = 0 
	anim_escudo.play("default") 
	
	print("Escudo Ativado! Proteção por 4 segundos.")

	await get_tree().create_timer(duracao_escudo).timeout
	
	escudo_ativo = false
	escudo_area.visible = false
	escudo_area.set_deferred("monitoring", false)
	
	
	anim_escudo.stop() 
	
	
	print("Escudo desativado. Iniciando cooldown...")
	tempo_inicio_cooldown = Time.get_ticks_msec() # Registra o início dos 16s
	
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
	print("Game Over!")
	
	get_tree().call_deferred("reload_current_scene")
func limitar_na_tela():
	var largura_tela = get_viewport_rect().size.x
	global_position.x = clamp(global_position.x, 20, largura_tela - 20) 
