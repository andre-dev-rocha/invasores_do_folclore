extends Area2D

@onready var som_tiro = $SomTiro

# Configurações de Movimento (GDD 2.1 - Saci)
@export_group("Movimento Infinito")
@export var valor_pontos: int = 100 
@export var velocidade_descida: float = 80.0
@export var amplitude_horizontal: float = 90.0
@export var amplitude_vertical_laco: float = 60.0
@export var frequencia: float = 2.5

@export_group("Drops")
@export var chance_drop_municao: float = 0.1 # 10% de chance
@export var chance_drop_sucata: float = 0.7 # 70% de chance de sucata
# Referências de Cenas
var cena_item_municao = preload("res://scenes/entities/ammo_pack.tscn")
var cena_sucata = preload("res://scenes/entities/sucata_espacial.tscn") 
var cena_pipoca = preload("res://scenes/entities/pipoca_magica.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_ponto = preload("res://scenes/entities/ponto_flutuante.tscn")

var tempo_decorrido: float = 0.0
var x_inicial: float = 0.0
var y_base: float = 0.0 

func _ready():
	x_inicial = global_position.x
	y_base = global_position.y
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	$TimerTiro.timeout.connect(atirar_pipoca)

func _process(delta):
	tempo_decorrido += delta
	y_base += velocidade_descida * delta
	
	var t = tempo_decorrido * frequencia
	var oscilacao_x = sin(t) * amplitude_horizontal
	var oscilacao_y_local = (sin(t) * cos(t)) * amplitude_vertical_laco
	
	global_position.x = x_inicial + oscilacao_x
	global_position.y = y_base + oscilacao_y_local

func atirar_pipoca():
	var pipoca = cena_pipoca.instantiate()
	if is_instance_valid(som_tiro):
		som_tiro.play()
	
	pipoca.global_position = global_position
	get_tree().current_scene.add_child(pipoca)

func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		morrer()
		area.queue_free()

func morrer():
	# 1. Efeito de Explosão
	var explosao = cena_explosao.instantiate()
	explosao.global_position = global_position
	get_tree().current_scene.add_child(explosao)
	
	# 2. Texto de Pontuação
	var ponto = cena_ponto.instantiate()
	ponto.global_position = global_position
	get_tree().current_scene.add_child(ponto)
	
	# 3. Adiciona pontos à fase
	if get_tree().current_scene.has_method("adicionar_pontos"):
		get_tree().current_scene.adicionar_pontos(valor_pontos)
	
	# 4. LÓGICA DE DROP DE MUNIÇÃO
	# randf() gera um número entre 0.0 e 1.0
	if randf() < chance_drop_municao:
		var pack = cena_item_municao.instantiate()
		pack.global_position = global_position
		# Adicionamos à cena principal para ele não sumir junto com o Saci
		get_tree().current_scene.call_deferred("add_child", pack)
		print("Saci deixou cair munição!")
	if randf() < chance_drop_sucata:
		var scrap = cena_sucata.instantiate()
		scrap.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", scrap)
	Global.registrar_morte_inimigo("Saci")
	queue_free()
