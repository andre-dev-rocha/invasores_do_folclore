extends Area2D

@export var velocidade = 400.0

func _ready():
	# Conecta o sinal do Notifier para deletar o laser automaticamente
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _process(delta):
	# Move o laser para cima (Y negativo na Godot)
	position.y -= velocidade * delta

func _on_screen_exited():
	# Remove o laser da memória quando ele sai da tela
	queue_free()
