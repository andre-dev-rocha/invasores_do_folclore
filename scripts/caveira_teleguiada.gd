extends Area2D

@export var velocidade: float = 250.0
@export var velocidade_curva: float = 2.0
@export var tempo_vida: float = 6.0

var jogador_ref: Node2D

func _ready():
	var area_callable = Callable(self, "_on_area_entered")
	if not area_entered.is_connected(area_callable):
		area_entered.connect(area_callable)

	_atualizar_jogador_ref()
	await get_tree().create_timer(tempo_vida).timeout
	queue_free()

func _process(delta):
	if not is_instance_valid(jogador_ref):
		_atualizar_jogador_ref()

	if is_instance_valid(jogador_ref):
		var direcao_alvo = global_position.direction_to(jogador_ref.global_position)
		var angulo_desejado = direcao_alvo.angle()
		rotation = lerp_angle(rotation, angulo_desejado, velocidade_curva * delta)

	var direcao_frente = Vector2.RIGHT.rotated(rotation)
	global_position += direcao_frente * velocidade * delta

func _on_area_entered(area):
	var jogador = _obter_jogador_por_area(area)
	if jogador:
		jogador.receber_dano()
		queue_free()

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

func _obter_jogador_por_area(area) -> Node:
	if area.has_method("receber_dano"):
		return area

	var parent = area.get_parent()
	if parent and parent.has_method("receber_dano"):
		return parent

	return null
