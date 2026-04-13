extends Control

@onready var background_cordel = $BackgroundLivro
@onready var btn_proximo = $BotaoProximo
@onready var btn_anterior = $BotaoAnterior
var pagina_atual = 0

# Array contendo as imagens completas das páginas do cordel
var paginas_cordel = [
	preload("res://assets/backgrounds/pagina_1_cordel.png"),
	preload("res://assets/backgrounds/pagina_2_cordel.png"),
	preload("res://assets/backgrounds/pagina_3_cordel.png")
]

func _ready():
	# Conecta os cliques dos botões
	btn_proximo.pressed.connect(_on_btn_proximo_pressed)
	btn_anterior.pressed.connect(_on_btn_anterior_pressed)
	
	# Carrega a primeira página assim que a cena abre
	atualizar_pagina()

func _on_btn_proximo_pressed():
	pagina_atual += 1
	
	# Verifica se ainda tem páginas para mostrar
	if pagina_atual < paginas_cordel.size():
		atualizar_pagina()
	else:
		iniciar_jogo()
func finalizar_historia():
	get_tree().change_scene_to_file("res://scenes/levels/fase_1.tscn")
func _on_btn_anterior_pressed():
	# Só volta a página se não estivermos na primeira (índice 0)
	if pagina_atual > 0:
		pagina_atual -= 1
		atualizar_pagina()

func atualizar_pagina():
	# Troca a textura inteira do fundo para a imagem da página atual
	background_cordel.texture = paginas_cordel[pagina_atual]
	
	# --- Lógica do Botão Próximo ---
	if pagina_atual == paginas_cordel.size() - 1:
		btn_proximo.text = "Iniciar Batalha!"
	else:
		btn_proximo.text = "Próximo" # Restaura o texto caso o jogador volte da última página
		
	# --- Lógica do Botão Anterior ---
	if pagina_atual == 0:
		btn_anterior.visible = false # Esconde na primeira página
	else:
		btn_anterior.visible = true  # Mostra nas outras páginas

func iniciar_jogo():
	get_tree().change_scene_to_file("res://scenes/levels/fase_1.tscn")
