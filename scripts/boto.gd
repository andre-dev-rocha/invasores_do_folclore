extends Area2D

# --- CONFIGURAÇÕES EXPORTADAS ---
@export_group("Atributos")
@export var vidas: int = 6
@export var valor_pontos: int = 250
var direcao_movimento: Vector2 = Vector2.DOWN
var cena_ponto_flutuante = preload("res://scenes/entities/ponto_flutuante.tscn")
@export var velocidade_cruzeiro: float = 90.0

@export_group("Movimento Nado Estelar")
@export var velocidade_descida: float = 30.0
@export var amplitude: float = 60.0
@export var frequencia: float = 1.0

@export_group("Drops")
@export var chance_drop_municao: float = 0.35 
@export var chance_drop_sucata_boto: float = 0.7 

# --- REFERÊNCIAS DE CENA ---
var cena_item_municao = preload("res://scenes/entities/ammo_pack.tscn")
var cena_sucata = preload("res://scenes/entities/sucata_espacial.tscn")
var cena_missel = preload("res://scenes/entities/missel_boto.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

@onready var anim = $AnimatedSprite2D
@onready var timer_tiro = %TimerGranada # Mantive o nome %TimerGranada para não quebrar sua cena, mas recomendo renomear no editor depois!
@onready var canhao_esq = $CanhaoEsq
@onready var canhao_dir = $CanhaoDir

var tempo_decorrido: float = 0.0
var x_inicial: float = 0.0

func _ready():
	x_inicial = global_position.x
	
	# CORREÇÃO: Agora o timer chama a função atirar() dos mísseis
	timer_tiro.timeout.connect(atirar)
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func configurar_direcao(nova_direcao: Vector2):
	direcao_movimento = nova_direcao
	rotation = 0

func _process(delta):
	tempo_decorrido += delta
	
	var movimento_base = direcao_movimento * velocidade_cruzeiro * delta
	var perpendicular = Vector2(-direcao_movimento.y, direcao_movimento.x)
	var oscilacao = perpendicular * sin(tempo_decorrido * frequencia) * (amplitude * delta)
	
	global_position += movimento_base + oscilacao

func atirar():
	# 1. Animação de ataque (se existir)
	if anim.sprite_frames.has_animation("atacar"):
		anim.play("atacar")
	
	# --- MÍSSIL ESQUERDO ---
	var missel_esq = cena_missel.instantiate()
	missel_esq.global_position = canhao_esq.global_position
	# Define a direção inicial inclinada para a esquerda e um pouco para baixo
	missel_esq.direcao_atual = Vector2(-1.0, 0.2).normalized()
	get_tree().current_scene.call_deferred("add_child", missel_esq)
	
	# --- MÍSSIL DIREITO ---
	var missel_dir = cena_missel.instantiate()
	missel_dir.global_position = canhao_dir.global_position
	# Define a direção inicial inclinada para a direita e um pouco para baixo
	missel_dir.direcao_atual = Vector2(1.0, 0.2).normalized()
	get_tree().current_scene.call_deferred("add_child", missel_dir)
	
	# 4. Áudio de tiro
	if has_node("SomTiro"):
		$SomTiro.play()
		
	print("Boto disparou mísseis teleguiados em arco!")
	
	# 5. Volta a animação ao normal
	if anim.sprite_frames.has_animation("default"):
		anim.play("default")
	elif anim.sprite_frames.has_animation("nado"):
		anim.play("nado")

func receber_dano():
	vidas -= 1
	modulate = Color(10, 10, 10) 
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1) 
	
	if vidas <= 0:
		morrer()

func morrer():
	var explosao_inst = cena_explosao.instantiate() 
	explosao_inst.global_position = global_position
	get_tree().current_scene.add_child(explosao_inst)
	
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
	Global.registrar_morte_inimigo("Boto")
	queue_free() # Destrói o inimigo

	if randf() < chance_drop_municao:
		var pack = cena_item_municao.instantiate()
		pack.global_position = global_position
		get_tree().current_scene.add_child(pack)
		
	if randf() < chance_drop_sucata_boto:
		for i in range(2): 
			var scrap = cena_sucata.instantiate()
			scrap.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			get_tree().current_scene.call_deferred("add_child", scrap)
			
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		receber_dano()
		area.queue_free()
