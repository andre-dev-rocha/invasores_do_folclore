extends Area2D

@export var velocidade: float = 120.0
@export var ganho_municao: int = 25

func _process(delta):
	# Move para baixo
	global_position.y += velocidade * delta
	
func _ready():
	print("Caixa de munição pronta e monitorando!")
	
# Esta é a função que o sinal vai chamar
func _on_area_entered(area):
	print("Colisão detectada com o nó: ", area.name)
	if area.name == "Hitbox" or area.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("adicionar_municao"):
			player.adicionar_municao(ganho_municao)
			print("Munição enviada!")
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
