extends CanvasLayer

# Referências usando Unique Names
@onready var menu_principal = %VBoxMenuPrincipal
@onready var confirmacao = %VBoxConfirmacao

func _ready():
	$SomGameOver.play()
	# Garante que a confirmação comece escondida
	confirmacao.visible = false
	menu_principal.visible = true

func _on_btn_tentar_novamente_pressed():
	get_tree().paused = false
	
	# Detecta qual é a cena atual que chamou o Game Over
	var cena_atual = get_tree().current_scene
	
	if cena_atual is Fase1:
		Fase1.pular_intro_proxima_vez = true
	elif cena_atual is Fase2:
		Fase2.pular_intro_fase2 = true
	elif cena_atual is Fase4:
		Fase4.pular_intro_fase4 = true
		
	Global.restaurar_checkpoint_sucata()
	get_tree().reload_current_scene()

func _on_btn_menu_principal_pressed():
	# Em vez de sair, mostra a confirmação
	menu_principal.visible = false
	confirmacao.visible = true

# --- BOTÕES DE CONFIRMAÇÃO ---

func _on_btn_nao_pressed():
	# Arrependeu? Volta para a tela de Game Over
	confirmacao.visible = false
	menu_principal.visible = true

func _on_btn_sim_pressed():
	# Confirmou? Volta para o menu do jogo
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu_principal.tscn")
