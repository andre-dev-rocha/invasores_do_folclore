extends Area2D

# Velocidade definida no GDD (ajustável no inspetor)
@export var velocidade : float = 500.0

# Variável de segurança para evitar que um único tiro conte dois acertos no mesmo frame
var acerto_registrado: bool = false

func _ready():
	# Conecta o sinal para se auto-destruir ao sair da tela
	if has_node("VisibleOnScreenNotifier2D") and not $VisibleOnScreenNotifier2D.screen_exited.is_connected(_on_screen_exited):
		$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

	# CORREÇÃO: Força a conexão do sinal de colisão via código para garantir que rode
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	# (Opcional mas recomendado) Conecta colisões físicas, caso algum inimigo seja CharacterBody2D
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta):
	# Move para cima (Y negativo na Godot)
	position.y -= velocidade * delta

func _on_screen_exited():
	# Limpa da memória para não pesar o jogo
	queue_free()

func _on_area_entered(area):
	_verificar_acerto(area)

func _on_body_entered(body):
	_verificar_acerto(body)

func _verificar_acerto(alvo):
	# Se já registrou, ignora
	if acerto_registrado: 
		return
		
	# Trava de segurança: Ignora a própria nave do jogador e o escudo
	if alvo.is_in_group("player"): 
		return
		
	# Verifica se bateu em algo válido (inimigos, chefe ou objetos destrutíveis)
	if alvo.is_in_group("inimigos") or alvo.is_in_group("boss") or alvo.has_method("receber_dano"):
		acerto_registrado = true
		Global.registrar_tiro_acertado() # AGORA A PRECISÃO VAI SUBIR!
		
		# Aplica o dano se o inimigo tiver a função preparada
		if alvo.has_method("receber_dano"):
			alvo.receber_dano()
			
		queue_free()
