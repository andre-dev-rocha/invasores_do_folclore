extends Area2D

signal derrotado

@export_group("Atributos do Chefe")
@export var hp_maximo: float = 8000.0
@export var valor_pontos: int = 50000
@export var dano_tiro_jogador: float = 25.0

@export_group("Ciclo de Habilidades")
@export var tempo_entre_habilidades: float = 1.5

@export_group("1. Laser")
@export var velocidade_rotacao_raio: float = 1.2
@export var duracao_laser: float = 3.5
@export var intervalo_dano_laser: float = 0.6

@export_group("2. Puxao da Nave")
@export var forca_atracao: float = 250.0
@export var duracao_atracao: float = 4.5

@export_group("3. Teleguiado")
@export var quantidade_caveiras: int = 6
@export var intervalo_caveiras: float = 0.3

@export_group("4. Breu Absoluto")
@export var duracao_breu: float = 8.0
@export var cura_breu_por_segundo: float = 0.04

enum Estado { SURGINDO, IDLE, RAIO_PESADELO, ATRACAO, CAVEIRAS, BREU_ABSOLUTO, MORTO }

const SEQUENCIA_HABILIDADES = [
	Estado.RAIO_PESADELO,
	Estado.ATRACAO,
	Estado.CAVEIRAS,
	Estado.BREU_ABSOLUTO,
]

var hp_atual: float
var estado_atual: int = Estado.SURGINDO
var indice_habilidade: int = 0
var jogador_ref: Node2D = null
var morreu: bool = false
var tempo_para_dano_laser: float = 0.0

@onready var sprite = $Sprite2D
@onready var laser_area = $LaserArea
@onready var timer_habilidade = $TimerHabilidade

var cena_caveira = preload("res://scenes/entities/caveira_teleguiada.tscn")
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

func _ready():
	hp_atual = hp_maximo
	_atualizar_jogador_ref()
	_configurar_colisoes()
	_conectar_sinais()
	_iniciar_entrada()

func _process(delta):
	if morreu:
		return

	match estado_atual:
		Estado.RAIO_PESADELO:
			_executar_raio_pesadelo(delta)
		Estado.ATRACAO:
			_executar_atracao(delta)
		Estado.BREU_ABSOLUTO:
			_executar_cura_breu(delta)

func _configurar_colisoes():
	collision_layer = 2
	collision_mask = 9
	monitoring = true
	monitorable = true

	laser_area.visible = false
	laser_area.collision_layer = 0
	laser_area.collision_mask = 1
	laser_area.monitorable = false
	laser_area.monitoring = false

func _conectar_sinais():
	var timer_callable = Callable(self, "_on_timer_habilidade_timeout")
	if not timer_habilidade.timeout.is_connected(timer_callable):
		timer_habilidade.timeout.connect(timer_callable)

	var dano_callable = Callable(self, "_on_area_entered")
	if not area_entered.is_connected(dano_callable):
		area_entered.connect(dano_callable)

	var laser_callable = Callable(self, "_on_laser_area_entered")
	if not laser_area.area_entered.is_connected(laser_callable):
		laser_area.area_entered.connect(laser_callable)

func _iniciar_entrada():
	var centro_tela = get_viewport_rect().size.x / 2.0
	global_position = Vector2(centro_tela, -200)

	var tween = create_tween()
	tween.tween_property(self, "global_position:y", 180.0, 3.0).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_iniciar_combate)

func _iniciar_combate():
	if morreu or not is_inside_tree():
		return

	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _agendar_proxima_habilidade(tempo: float):
	timer_habilidade.stop()
	timer_habilidade.start(tempo)

func _on_timer_habilidade_timeout():
	if morreu or not is_inside_tree():
		return

	match estado_atual:
		Estado.IDLE:
			_escolher_proxima_habilidade()
		Estado.RAIO_PESADELO:
			_encerrar_raio_pesadelo()
		Estado.ATRACAO:
			_encerrar_atracao()
		Estado.BREU_ABSOLUTO:
			_encerrar_breu()

func _escolher_proxima_habilidade():
	var habilidade = SEQUENCIA_HABILIDADES[indice_habilidade]
	indice_habilidade = (indice_habilidade + 1) % SEQUENCIA_HABILIDADES.size()

	match habilidade:
		Estado.RAIO_PESADELO:
			_preparar_raio_pesadelo()
		Estado.ATRACAO:
			_iniciar_atracao()
		Estado.CAVEIRAS:
			_iniciar_chuva_caveiras()
		Estado.BREU_ABSOLUTO:
			_iniciar_breu_absoluto()

func _preparar_raio_pesadelo():
	estado_atual = Estado.RAIO_PESADELO
	tempo_para_dano_laser = 0.0

	var centro_tela = Vector2(get_viewport_rect().size.x / 2.0, 180.0)
	var tween = create_tween()
	tween.tween_property(self, "global_position", centro_tela, 1.2).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func(): modulate = Color(3.0, 0.5, 0.5))
	tween.tween_interval(0.8)
	tween.tween_callback(_ativar_laser)

func _ativar_laser():
	if morreu or not is_inside_tree():
		return

	modulate = Color(1.0, 1.0, 1.0)
	laser_area.visible = true
	laser_area.set_deferred("monitoring", true)
	_agendar_proxima_habilidade(duracao_laser)

func _executar_raio_pesadelo(delta):
	_atualizar_jogador_ref()
	if is_instance_valid(jogador_ref):
		var direcao = global_position.direction_to(jogador_ref.global_position)
		var angulo_alvo = direcao.angle() - PI / 2.0
		rotation = lerp_angle(rotation, angulo_alvo, velocidade_rotacao_raio * delta)

	if not laser_area.monitoring:
		return

	tempo_para_dano_laser -= delta
	if tempo_para_dano_laser > 0.0:
		return

	for area in laser_area.get_overlapping_areas():
		if _causar_dano_no_jogador(area):
			tempo_para_dano_laser = intervalo_dano_laser
			break

func _encerrar_raio_pesadelo():
	laser_area.visible = false
	laser_area.set_deferred("monitoring", false)

	var tween = create_tween()
	tween.tween_property(self, "rotation", 0.0, 0.8)

	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _iniciar_atracao():
	estado_atual = Estado.ATRACAO
	modulate = Color(0.8, 0.2, 1.0)
	_agendar_proxima_habilidade(duracao_atracao)

func _executar_atracao(delta):
	_atualizar_jogador_ref()
	if not is_instance_valid(jogador_ref):
		return

	var direcao_puxao = jogador_ref.global_position.direction_to(global_position)
	jogador_ref.global_position += direcao_puxao * forca_atracao * delta

func _encerrar_atracao():
	modulate = Color(1.0, 1.0, 1.0)
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _iniciar_chuva_caveiras():
	estado_atual = Estado.CAVEIRAS
	modulate = Color(0.65, 0.75, 1.0)

	for i in range(quantidade_caveiras):
		if morreu or not is_inside_tree():
			return

		_spawnar_caveira()
		await get_tree().create_timer(intervalo_caveiras).timeout

	if morreu or not is_inside_tree():
		return

	modulate = Color(1.0, 1.0, 1.0)
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _spawnar_caveira():
	var parent = get_parent()
	if parent == null:
		return

	var caveira = cena_caveira.instantiate()
	caveira.global_position = global_position + Vector2(randf_range(-80.0, 80.0), 50.0)

	_atualizar_jogador_ref()
	if is_instance_valid(jogador_ref):
		caveira.rotation = caveira.global_position.direction_to(jogador_ref.global_position).angle()

	parent.add_child(caveira)

func _iniciar_breu_absoluto():
	estado_atual = Estado.BREU_ABSOLUTO
	modulate = Color(0.45, 0.45, 0.6)

	var canvas_modulate = _pegar_canvas_modulate()
	if canvas_modulate:
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(0.05, 0.05, 0.05, 1.0), 2.0)

	_agendar_proxima_habilidade(duracao_breu)

func _executar_cura_breu(delta):
	if hp_atual < hp_maximo:
		hp_atual += hp_maximo * cura_breu_por_segundo * delta
		hp_atual = min(hp_atual, hp_maximo)

func _encerrar_breu():
	_restaurar_luz()

	if morreu:
		return

	modulate = Color(1.0, 1.0, 1.0)
	estado_atual = Estado.IDLE
	_agendar_proxima_habilidade(tempo_entre_habilidades)

func _restaurar_luz():
	var canvas_modulate = _pegar_canvas_modulate()
	if canvas_modulate:
		var tween = create_tween()
		tween.tween_property(canvas_modulate, "color", Color(1.0, 1.0, 1.0, 1.0), 2.0)

func _on_area_entered(area):
	if morreu:
		return

	if area.is_in_group("laser_player"):
		_receber_dano(dano_tiro_jogador)
		area.queue_free()

func receber_dano(dano: float = -1.0):
	if dano < 0.0:
		dano = dano_tiro_jogador
	_receber_dano(dano)

func _receber_dano(dano: float):
	if morreu:
		return

	hp_atual -= dano

	if hp_atual <= 0.0:
		_morrer()
		return

	var cor_original = modulate
	modulate = Color(10.0, 10.0, 10.0)
	await get_tree().create_timer(0.05).timeout
	if not morreu and is_inside_tree():
		modulate = cor_original

func _morrer():
	if morreu:
		return

	morreu = true
	estado_atual = Estado.MORTO
	timer_habilidade.stop()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	laser_area.visible = false
	laser_area.set_deferred("monitoring", false)
	_restaurar_luz()

	if is_inside_tree():
		var cena_atual = get_tree().current_scene
		if cena_atual and cena_atual.has_method("adicionar_pontos"):
			cena_atual.adicionar_pontos(valor_pontos)

	var parent = get_parent()
	if parent:
		var explosao = cena_explosao.instantiate()
		explosao.global_position = global_position
		explosao.scale = Vector2(4.0, 4.0)
		parent.call_deferred("add_child", explosao)

	derrotado.emit()
	queue_free()

func _on_laser_area_entered(area):
	if estado_atual == Estado.RAIO_PESADELO:
		_causar_dano_no_jogador(area)

func _causar_dano_no_jogador(area) -> bool:
	var jogador = _obter_jogador_por_area(area)
	if jogador == null:
		return false

	jogador.receber_dano()
	return true

func _obter_jogador_por_area(area) -> Node:
	if area.has_method("receber_dano"):
		return area

	var parent = area.get_parent()
	if parent and parent.has_method("receber_dano"):
		return parent

	return null

func _atualizar_jogador_ref():
	if not is_inside_tree():
		return

	for node in get_tree().get_nodes_in_group("player"):
		if node is Node2D and node.has_method("receber_dano"):
			jogador_ref = node
			return

		if node is Area2D:
			var parent = node.get_parent()
			if parent is Node2D and parent.has_method("receber_dano"):
				jogador_ref = parent
				return

	jogador_ref = null

func _pegar_canvas_modulate():
	if not is_inside_tree():
		return null

	var cena_atual = get_tree().current_scene
	if cena_atual == null:
		return null

	return cena_atual.get_node_or_null("CanvasModulate")
