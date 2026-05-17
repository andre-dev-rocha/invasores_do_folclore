extends Area2D

# --- CONFIGURAÇÕES EXPORTADAS ---
@export_group("Atributos")
@export var vidas: int = 3 # Coloquei 5 para ela ser um pouco mais resistente que o Boto
@export var valor_pontos: int = 300
var cena_ponto_flutuante = preload("res://scenes/entities/ponto_flutuante.tscn")
var direcao_movimento: Vector2 = Vector2.DOWN 
@export var velocidade_cruzeiro: float = 60.0

@export_group("Movimento Bruxaria Sideral")
@export var amplitude: float = 65.0
@export var frequencia: float = 1.2

@export_group("Drops")
@export var chance_drop_municao: float = 0.5 
@export var chance_drop_sucata_cuca: float = 0.8 

# --- REFERÊNCIAS ---
var cena_item_municao = preload("res://scenes/entities/ammo_pack.tscn")
var cena_sucata = preload("res://scenes/entities/sucata_espacial.tscn")
var cena_bola_energia = preload("res://scenes/entities/bola_energia.tscn") # A bola de energia de volta!
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

@onready var anim = $AnimatedSprite2D
@onready var timer_tiro = %TimerTiro # Crie um Timer na cena chamado "TimerTiro"

var tempo_decorrido: float = 0.0

func _ready():
	# Conecta o sinal do timer para atirar
	timer_tiro.timeout.connect(atirar_energia)
	
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func configurar_direcao(nova_direcao: Vector2):
	direcao_movimento = nova_direcao
	rotation = 0

func _process(delta):
	tempo_decorrido += delta
	
	# 1. Movimento Base
	var movimento_base = direcao_movimento * velocidade_cruzeiro * delta
	
	# 2. Voo Sinuoso (Idêntico ao nado do Boto)
	var perpendicular = Vector2(-direcao_movimento.y, direcao_movimento.x)
	var oscilacao = perpendicular * sin(tempo_decorrido * frequencia) * (amplitude * delta)
	
	global_position += movimento_base + oscilacao

func atirar_energia():
	# Toca animação se houver
	if anim and anim.sprite_frames.has_animation("atacar"):
		anim.play("atacar")
	
	# Dispara a bola de energia
	var bola = cena_bola_energia.instantiate()
	bola.global_position = global_position + Vector2(0, 40) # Ajuste a posição para sair do caldeirão
	
	# Pinta a bola de energia de VERDE RADIOATIVO
	bola.modulate = Color(1, 1, 1, 1.0)
	
	get_tree().current_scene.call_deferred("add_child", bola)
	
	if has_node("SomTiro"):
		$SomTiro.play()

	if anim and anim.sprite_frames.has_animation("default"):
		anim.play("default")

func receber_dano():
	vidas -= 1
	# Feedback visual
	modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1) 
	
	if vidas <= 0:
		morrer()

func morrer():
	var explosao_inst = cena_explosao.instantiate() 
	explosao_inst.global_position = global_position
	explosao_inst.scale = Vector2(1.5, 1.5) # Uma explosão um pouco maior
	get_tree().current_scene.call_deferred("add_child", explosao_inst)
	
# Adiciona os pontos ao placar geral da fase
	if get_tree().current_scene.has_method("adicionar_pontos"):
		get_tree().current_scene.adicionar_pontos(valor_pontos)
		
	var popup_pontos = cena_ponto_flutuante.instantiate()
	popup_pontos.global_position = global_position # Nasce no mesmo lugar do inimigo
	
	var label = popup_pontos.get_node_or_null("Label")
	if label:
		label.text = str("+ ", valor_pontos)
	elif popup_pontos is Label:
		# Caso a raiz da sua cena já seja o próprio Label
		popup_pontos.text = str(valor_pontos)
		
	get_tree().current_scene.call_deferred("add_child", popup_pontos)
	Global.registrar_morte_inimigo("Cuca")
	queue_free() # Destrói o inimigo
	if randf() < chance_drop_municao:
		var pack = cena_item_municao.instantiate()
		pack.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", pack)
		
	if randf() < chance_drop_sucata_cuca:
		# A Cuca é um inimigo mais forte, então pode dropar mais sucata
		for i in range(3): 
			var scrap = cena_sucata.instantiate()
			scrap.global_position = global_position + Vector2(randf_range(-25, 25), randf_range(-25, 25))
			get_tree().current_scene.call_deferred("add_child", scrap)
			
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		receber_dano()
		area.queue_free()
