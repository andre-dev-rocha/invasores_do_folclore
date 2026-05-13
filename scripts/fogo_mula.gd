extends Area2D

@export var velocidade: float = 350.0
# Direção padrão (será sobrescrita pela Mula no momento do disparo)
var direcao_movimento: Vector2 = Vector2.DOWN 

func _ready():
	# Se você já conectou os sinais pelo Editor, não precisa destas linhas.
	# Coloquei aqui por precaução para garantir que funcione.
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if has_node("VisibleOnScreenNotifier2D"):
		var notifier = $VisibleOnScreenNotifier2D
		if not notifier.screen_exited.is_connected(queue_free):
			notifier.screen_exited.connect(queue_free)

func _process(delta):
	# Movimento baseado na direção (X e Y) em vez de apenas descer
	position += direcao_movimento * velocidade * delta
	
	# Opcional: Faz o fogo "olhar" para a direção que está indo
	rotation = direcao_movimento.angle() - (PI / 2)

func _on_area_entered(area):
	# Sistema padrão de dano no Player ou Escudo
	if area.is_in_group("player") or area.get_parent().is_in_group("player") or area.is_in_group("escudo"):
		var alvo = area
		
		# Procura o método de dano no pai se bateu na Hitbox
		if not alvo.has_method("receber_dano") and alvo.get_parent().has_method("receber_dano"):
			alvo = alvo.get_parent()
		
		if alvo.has_method("receber_dano"):
			alvo.receber_dano()
			
		queue_free() # Destrói o fogo após o impacto


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.
