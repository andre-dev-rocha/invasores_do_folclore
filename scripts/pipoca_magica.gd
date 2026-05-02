extends Area2D

@export var velocidade : float = 300.0

func _ready():
	if not $VisibleOnScreenNotifier2D.screen_exited.is_connected(queue_free):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _process(delta):
	position.y += velocidade * delta

# Função única para processar qualquer tipo de impacto
func _on_impacto(objeto):
	# 1. Verifica se atingiu o Player (direto ou pela Hitbox) ou o Escudo
	if objeto.is_in_group("player") or objeto.get_parent().is_in_group("player") or objeto.name == "EscudoArea":
		
		var alvo = objeto
		
		# Se atingiu a Hitbox, mas o script está no Player (pai)
		if not alvo.has_method("receber_dano") and alvo.get_parent().has_method("receber_dano"):
			alvo = alvo.get_parent()
		
		# 2. Se o alvo tem a função, aplica o dano
		if alvo.has_method("receber_dano"):
			alvo.receber_dano()
			print("Pipoca atingiu: ", alvo.name)
		
		# 3. ESSENCIAL: O queue_free() tem que ficar FORA do 'if' do método,
		# mas DENTRO do 'if' do grupo player/escudo.
		queue_free()

# Conecte os sinais do Editor nestas funções:
func _on_area_entered(area):
	_on_impacto(area)

func _on_body_entered(body):
	_on_impacto(body)
