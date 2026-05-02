extends Area2D

@export_group("Configurações da Granada")
@export var tempo_detonacao: float = 4.0
@export var raio_atracao: float = 400.0      # Distância de detecção
@export var forca_atracao: float = 100.0       # Velocidade de perseguição
@export var velocidade_descida_base: float = 80.0

var tempo_vida: float = 0.0
var player = null
var explodiu: bool = false

# Cores para a transição (Rosa Neon para Vermelho Alerta)
var cor_rosa = Color(1.0, 1.0, 1)
var cor_vermelha = Color(1.0, 0.0, 0.0)

@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
var cena_explosao = preload("res://scenes/entities/explosao.tscn")

func _ready():
	# Busca a referência do player (o nó que tem o script)
	player = get_tree().get_first_node_in_group("player")
	
	# Se o primeiro nó do grupo for a Hitbox (Area2D), pegamos o pai (Player)
	if player is Area2D:
		player = player.get_parent()

	# Inicia a animação de pulsar
	if anim.has_animation("pre_explosao"):
		anim.play("pre_explosao")
	

func _process(delta):
	if explodiu: return
	
	tempo_vida += delta
	var progresso = tempo_vida / tempo_detonacao 
	
	sprite.modulate = cor_rosa.lerp(cor_vermelha, progresso)
	anim.speed_scale = 1.0 + (progresso * 3.0)
	
	if player and is_instance_valid(player):
		var distancia = global_position.distance_to(player.global_position)
		
		if distancia < raio_atracao:
			var direcao = (player.global_position - global_position).normalized()
			global_position += direcao * forca_atracao * delta
		else:
			global_position.y += velocidade_descida_base * delta
	
	if tempo_vida >= tempo_detonacao:
		detonar()

func detonar():
	if explodiu: return
	explodiu = true
	
	var explosion = cena_explosao.instantiate()
	explosion.global_position = global_position
	explosion.scale = Vector2(2.5, 2.5) 
	get_tree().current_scene.add_child(explosion)
	
	# Lógica de dano por proximidade corrigida
	if player and is_instance_valid(player):
		var distancia_final = global_position.distance_to(player.global_position)
		if distancia_final < 120: 
			if player.has_method("receber_dano"):
				player.receber_dano()
			
	queue_free()
