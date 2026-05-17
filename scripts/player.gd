extends CharacterBody2D

# Pegamos a referência do novo nó
@onready var anim_sprite = $Sprite2D

@export_group("Movimentação")
@export var velocidade: float = 400.0

@export_group("Munição")
@export var municao_maxima: int = 80
var municao_atual: int = 40 # Começa carregado

@export_group("Combate")
@export var cadencia_disparo: float = 0.4 
var pode_atirar: bool = true 

@export_group("Escudo")
@export var duracao_escudo: float = 7.0      
@export var tempo_cooldown_escudo: float = 28.0 

# Variáveis Internas
var vidas = 3
var escudo_disponivel = true
var escudo_ativo = false
var tempo_inicio_cooldown = 0.0

# Referências de Áudio e Volume
@onready var som_motor = $SomMotor
@onready var som_escudo = $SomEscudo
@onready var som_foguete = $SomFoguete
var volume_idle: float = -15.0  
var volume_movimento: float = -5.0 
var suavidade_volume: float = 5.0 

# Referências de Cena e Nós
@onready var escudo_area = $EscudoArea
@onready var ponto_disparo = $PontoDisparo
@onready var anim_escudo = $EscudoArea/AnimatedSprite2D
@onready var hud = get_tree().current_scene.find_child("HUD")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_laser = preload("res://scenes/entities/foguete.tscn")

# --- FUNÇÃO READY ATUALIZADA ---
func _ready():
	add_to_group("player")
	atualizar_visual_nave()
	if has_node("Hitbox"):
		$Hitbox.add_to_group("player")
	
	# 1. CARREGA OS UPGRADES DA OFICINA (SINGLETON GLOBAL)
	# Isso sobrescreve os valores padrão pelos valores melhorados
	velocidade = Global.get_velocidade()
	vidas = Global.get_vidas()
	cadencia_disparo = Global.get_cadencia()
	duracao_escudo = Global.get_duracao_escudo()
	
	# 2. DEBUG PARA CONSOLE
	print("--- ZÉ GALÁXIA TURBINADO ---")
	print("Vidas: ", vidas, " | Vel: ", velocidade, " | Cadência: ", cadencia_disparo)
	
	# 3. SINCRONIZA O HUD COM OS NOVOS VALORES
	if hud:
		await get_tree().process_frame
		if hud.has_method("atualizar_vidas"):
			hud.atualizar_vidas(vidas)
		if hud.has_method("atualizar_municao"):
			hud.atualizar_municao(municao_atual)
		if hud.has_method("atualizar_sucata"):
			hud.atualizar_sucata(Global.total_sucatas)

func _process(_delta):
	atualizar_hud_escudo()
	
	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("atirar")) and pode_atirar:
		atirar()

func _physics_process(_delta):
	var direcao = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direcao != Vector2.ZERO:
		velocity = direcao * velocidade
		som_motor.volume_db = lerp(som_motor.volume_db, volume_movimento, suavidade_volume * _delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, velocidade)
		som_motor.volume_db = lerp(som_motor.volume_db, volume_idle, suavidade_volume * _delta)
	
	move_and_slide()
	limitar_na_tela()
	
	if Input.is_action_just_pressed("escudo") and escudo_disponivel:
		iniciar_ciclo_escudo()

func atirar():
	if municao_atual <= 0:
		print("Sem munição!")
		return
		
	pode_atirar = false 
	municao_atual -= 1
	
	if hud and hud.has_method("atualizar_municao"):
		hud.atualizar_municao(municao_atual)
		
	var laser = cena_laser.instantiate()
	laser.z_index = 10 
	laser.global_position = ponto_disparo.global_position
	get_tree().current_scene.add_child(laser)
	
	if som_foguete:
		som_foguete.play()
	
	# Usa a cadência vinda do Global
	await get_tree().create_timer(cadencia_disparo).timeout
	pode_atirar = true

func adicionar_municao(quantidade: int):
	municao_atual = clamp(municao_atual + quantidade, 0, municao_maxima)
	if hud and hud.has_method("atualizar_municao"):
		hud.atualizar_municao(municao_atual)

func iniciar_ciclo_escudo():
	escudo_ativo = true
	escudo_disponivel = false 
	escudo_area.visible = true
	escudo_area.set_deferred("monitoring", true)
	
	if som_escudo:
		som_escudo.play()
	
	anim_escudo.frame = 0 
	anim_escudo.play("default") 
	
	# Usa a duração vinda do Global
	await get_tree().create_timer(duracao_escudo).timeout
	
	escudo_ativo = false
	escudo_area.visible = false
	escudo_area.set_deferred("monitoring", false)
	
	if som_escudo:
		som_escudo.stop()
	
	anim_escudo.stop() 
	
	tempo_inicio_cooldown = Time.get_ticks_msec()
	
	await get_tree().create_timer(tempo_cooldown_escudo).timeout
	escudo_disponivel = true

func atualizar_hud_escudo():
	if hud == null: return
	
	if escudo_ativo:
		hud.atualizar_barra_escudo(100)
	elif not escudo_disponivel:
		var tempo_passado = (Time.get_ticks_msec() - tempo_inicio_cooldown) / 1000.0
		var porcentagem = (tempo_passado / tempo_cooldown_escudo) * 100
		hud.atualizar_barra_escudo(clamp(porcentagem, 0, 100))
	else:
		hud.atualizar_barra_escudo(100)
func _piscar_dano():
	# Agora aplicamos o modulate no AnimatedSprite2D
	var cor_original = anim_sprite.modulate
	anim_sprite.modulate = Color(10, 10, 10, 1) 
	await get_tree().create_timer(0.1).timeout
	
	if is_instance_valid(anim_sprite):
		anim_sprite.modulate = cor_original
	
func receber_dano():
	if escudo_ativo:
		return
	vidas -= 1
	atualizar_visual_nave()
	_piscar_dano()
	if hud and hud.has_method("atualizar_vidas"):
		hud.atualizar_vidas(vidas)
	
	if vidas <= 0:
		morrer()
func atualizar_visual_nave():
	if not is_instance_valid(anim_sprite): 
		return
		
	# Lógica simplificada para apenas dois estados
	if vidas <= 1:
		anim_sprite.play("danificada")
	else:
		anim_sprite.play("intacta")
func morrer():
	$Hitbox.set_deferred("disabled", true) 
	var explosao = cena_explosao.instantiate()
	explosao.global_position = global_position
	get_tree().current_scene.add_child(explosao)
	
	visible = false
	set_physics_process(false) 
	set_process(false)
	
	if get_tree().current_scene.has_method("iniciar_game_over"):
		get_tree().current_scene.iniciar_game_over()

func limitar_na_tela():
	var limite_tela = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 30, limite_tela.x - 30)
	global_position.y = clamp(global_position.y, 30, limite_tela.y - 30)
