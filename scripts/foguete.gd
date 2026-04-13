extends Area2D

# Velocidade definida no GDD (ajustável no inspetor)
@export var velocidade : float = 500.0

func _ready():
	# Conecta o sinal para se auto-destruir ao sair da tela
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta):
	# Move para cima (Y negativo na Godot)
	position.y -= velocidade * delta

func _on_screen_exited():
	# Limpa da memória para não pesar o jogo
	queue_free()
