extends Area2D

@export_group("Atributos")
@export var vidas: int = 6
@export var valor_pontos: int = 400

@export_group("Galope Cósmico")
@export var velocidade: float = 160.0
@export var amplitude_galope: float = 45.0
@export var frequencia_galope: float = 5.0

var direcao_movimento: Vector2 = Vector2.RIGHT
var tempo_decorrido: float = 0.0
var x_base: float = 0.0
var y_inicial: float = 0.0

var cena_fogo = preload("res://scenes/entities/bola_energia.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

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
	var fogo = cena_fogo.instantiate()
	fogo.global_position = global_position + Vector2(0, 40)
	fogo.modulate = Color(1.0, 0.3, 0.0, 1.0)
	get_tree().current_scene.add_child(fogo)
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
	if get_tree().current_scene.has_method("adicionar_pontos"):
		get_tree().current_scene.adicionar_pontos(valor_pontos)
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("laser_player"):
		receber_dano()
		area.queue_free()
