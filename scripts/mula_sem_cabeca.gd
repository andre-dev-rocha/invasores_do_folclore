extends Area2D

@export_group("Atributos")
@export var vidas: int = 4
@export var valor_pontos: int = 400

@export_group("Galope Cósmico")
@export var velocidade: float = 100.0
@export var amplitude_galope: float = 15.0
@export var frequencia_galope: float = 5.0

@export var chance_drop_municao: float = 0.4 
@export var chance_drop_sucata_mula: float = 0.7
var direcao_movimento: Vector2 = Vector2.RIGHT
var tempo_decorrido: float = 0.0
var x_base: float = 0.0
var y_inicial: float = 0.0

var cena_ponto_flutuante = preload("res://scenes/entities/ponto_flutuante.tscn")
var cena_fogo = preload("res://scenes/entities/fogo_mula.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")
var cena_item_municao = preload("res://scenes/entities/ammo_pack.tscn")
var cena_sucata = preload("res://scenes/entities/sucata_espacial.tscn")

@onready var sprite = $Sprite2D
@onready var timer_fogo = %TimerFogo

func _ready():
	x_base = global_position.x
	y_inicial = global_position.y
	if direcao_movimento.x < 0:
		sprite.flip_h = true
	timer_fogo.timeout.connect(lancar_fogo)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func configurar_direcao(nova_direcao: Vector2):
	direcao_movimento = nova_direcao

func _process(delta):
	tempo_decorrido += delta
	x_base += direcao_movimento.x * velocidade * delta
	var galope_y = sin(tempo_decorrido * frequencia_galope) * amplitude_galope
	global_position.x = x_base
	global_position.y = y_inicial + galope_y

func lancar_fogo():
	var direcoes = [
		Vector2.DOWN,                  # Reto para baixo
		Vector2(-1, 1).normalized(),   # Diagonal Esquerda
		Vector2(1, 1).normalized()     # Diagonal Direita
	]

	for dir in direcoes:
		var fogo = cena_fogo.instantiate()
		fogo.global_position = global_position + Vector2(0, 40)
		
		# Pinta o sprite de laranja/fogo (caso o sprite original seja branco)
		fogo.modulate = Color(1.0, 0.4, 0.0, 1.0) 
		
		# Passa a direção exata para a variável que criamos no novo script
		fogo.direcao_movimento = dir
			
		get_tree().current_scene.call_deferred("add_child", fogo)

	if has_node("SomTiro"):
		$SomTiro.play()
func receber_dano():
	vidas -= 1
	modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	if vidas <= 0:
		morrer()

func morrer():
	var explosao = cena_explosao.instantiate()
	explosao.global_position = global_position
	explosao.scale = Vector2(2.0, 2.0)
	get_tree().current_scene.add_child(explosao)
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
	Global.registrar_morte_inimigo("Mula")
	queue_free() # Destrói o inimigo
	if randf() < chance_drop_municao:
		var pack = cena_item_municao.instantiate()
		pack.global_position = global_position
		get_tree().current_scene.add_child(pack)
		
	if randf() < chance_drop_sucata_mula:
		for i in range(2): 
			var scrap = cena_sucata.instantiate()
			scrap.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
			get_tree().current_scene.call_deferred("add_child", scrap)
			
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		receber_dano()
		area.queue_free()
