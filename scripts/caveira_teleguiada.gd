extends Area2D

@export var velocidade: float = 250.0
@export var velocidade_curva: float = 2.0 # O quão rápido ela consegue girar (menor = curva mais aberta)
var jogador_ref: Node2D

func _ready():
	jogador_ref = get_tree().get_first_node_in_group("player")
	# Destrói a caveira após 6 segundos para não ficar na tela eternamente
	await get_tree().create_timer(6.0).timeout
	queue_free()

func _process(delta):
	if is_instance_valid(jogador_ref):
		var direcao_alvo = global_position.direction_to(jogador_ref.global_position)
		var angulo_desejado = direcao_alvo.angle()
		
		# Faz a rotação interpolar (curvar suavemente) em direção ao alvo
		rotation = lerp_angle(rotation, angulo_desejado, velocidade_curva * delta)
		
	# Move sempre para "frente" baseada na própria rotação
	var direcao_frente = Vector2.RIGHT.rotated(rotation)
	global_position += direcao_frente * velocidade * delta

func _on_area_entered(area):
	if area.is_in_group("player"):
		area.receber_dano(1)
		queue_free()
