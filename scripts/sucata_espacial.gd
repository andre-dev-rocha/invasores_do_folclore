extends Area2D

@export var velocidade: float = 150.0

func _ready():
	# Garante que o sinal de colisão está conectado
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _process(delta):
	# Sucata descendo
	global_position.y += velocidade * delta

func _on_area_entered(area):
	# Verifica se quem tocou foi a Hitbox do player ou o Player
	if area.is_in_group("player") or area.get_parent().is_in_group("player"):
		# SOMA NO GLOBAL
		Global.total_sucatas += 5
		Global.sucatas_totais_coletadas += 5
		print("Sucata coletada! Total no inventário: ", Global.total_sucatas)
		var hud = get_tree().current_scene.find_child("HUD")
		if hud and hud.has_method("atualizar_sucata"):
			hud.atualizar_sucata(Global.total_sucatas)
		queue_free()
