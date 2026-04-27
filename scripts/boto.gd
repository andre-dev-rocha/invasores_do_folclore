extends Area2D

# --- CONFIGURAÇÕES EXPORTADAS ---
@export_group("Atributos")
@export var vidas: int = 4
@export var valor_pontos: int = 250
var direcao_movimento: Vector2 = Vector2.DOWN 
@export var velocidade_cruzeiro: float = 90.0
@export_group("Movimento Nado Estelar")
@export var velocidade_descida: float = 30.0
@export var amplitude: float = 60.0
@export var frequencia: float = 1.0

# --- REFERÊNCIAS ---
var cena_granada = preload("res://scenes/entities/bola_energia.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

@onready var anim = $AnimatedSprite2D
@onready var timer_granada = %TimerGranada

var tempo_decorrido: float = 0.0
var x_inicial: float = 0.0

func _ready():
	x_inicial = global_position.x
	# Conecta o sinal do timer para atirar
	timer_granada.timeout.connect(lancar_granada)
	# Conecta o sinal para sumir ao sair da tela
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func configurar_direcao(nova_direcao: Vector2):
	direcao_movimento = nova_direcao
	rotation = 0
func _process(delta):
	tempo_decorrido += delta
	
	# 1. Movimento Base lento e constante
	var movimento_base = direcao_movimento * velocidade_cruzeiro * delta
	
	# 2. Nado Estelar (Oscilação suave)
	var perpendicular = Vector2(-direcao_movimento.y, direcao_movimento.x)
	# Removi o multiplicador de 50 para você ter controle total pela variável 'amplitude'
	var oscilacao = perpendicular * sin(tempo_decorrido * frequencia) * (amplitude * delta)
	
	global_position += movimento_base + oscilacao
func lancar_granada():
	# 1. Tenta tocar a animação de ataque se ela existir
	if anim.sprite_frames.has_animation("atacar"):
		anim.play("atacar")
		
		# Só esperamos se a animação NÃO for um loop infinito
		if not anim.sprite_frames.get_animation_loop("atacar"):
			await anim.animation_finished
	
	# 2. LANÇA A BOLA DE ENERGIA (Agora essa linha sempre será lida)
	var granada = cena_granada.instantiate()
	granada.global_position = global_position + Vector2(0, 30)
	get_tree().current_scene.add_child(granada)
	
	if has_node("SomTiro"):
		$SomTiro.play()

	# 3. VOLTA PARA A ANIMAÇÃO PADRÃO (Apenas se ela existir)
	# Se você não tem 'default' ou 'nado', o Boto apenas continuará
	# exibindo o último frame da animação de ataque.
	if anim.sprite_frames.has_animation("default"):
		anim.play("default")
	elif anim.sprite_frames.has_animation("nado"):
		anim.play("nado")

func receber_dano():
	vidas -= 1
	# Feedback visual de dano (piscar branco)
	modulate = Color(10, 10, 10) # Brilho intenso
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1) # Volta ao normal
	
	if vidas <= 0:
		morrer()

func morrer():
	# Explosão
	var explosao_inst = cena_explosao.instantiate() # Mudei de 'exp' para 'explosao_inst'
	explosao_inst.global_position = global_position
	get_tree().current_scene.add_child(explosao_inst)
	
	# Pontuação (Se sua Fase tiver o método)
	if get_tree().current_scene.has_method("adicionar_pontos"):
		get_tree().current_scene.adicionar_pontos(valor_pontos)
	
	queue_free()

# Detecta impacto com o laser do player
func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		receber_dano()
		area.queue_free() # Destrói o laser
