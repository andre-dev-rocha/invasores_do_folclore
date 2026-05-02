extends Control

# Referências aos nós da interface
@onready var menu_buttons = $Opcoes
@onready var opcoes_panel = $OpcoesPanel

# Referências aos botões para conectar os sinais via código
@onready var btn_jogar = $Opcoes/BotaoJogar
@onready var btn_opcoes = $Opcoes/BotaoOpcoes
@onready var btn_creditos = $Opcoes/BotaoCreditos
@onready var btn_sair = $Opcoes/BotaoSair
@onready var btn_voltar_opcoes = $OpcoesPanel/VBoxContainer/BotaoVoltarOpcoes

@onready var slider_musica = $OpcoesPanel/VBoxContainer/SliderMusica
@onready var slider_efeitos = $OpcoesPanel/VBoxContainer/SliderEfeitos
# Pegando os índices (IDs) dos canais de áudio
var bus_musica_id = AudioServer.get_bus_index("Music")
var bus_efeitos_id = AudioServer.get_bus_index("SFX")

func _ready():
	opcoes_panel.visible = false
	
	btn_jogar.pressed.connect(_on_btn_jogar_pressed)
	btn_opcoes.pressed.connect(_on_btn_opcoes_pressed)
	btn_creditos.pressed.connect(_on_btn_creditos_pressed)
	btn_sair.pressed.connect(_on_btn_sair_pressed)
	btn_voltar_opcoes.pressed.connect(_on_btn_voltar_opcoes_pressed)
	
	slider_musica.value_changed.connect(_on_slider_musica_changed)
	slider_efeitos.value_changed.connect(_on_slider_efeitos_changed)
	
	# Inicializa os sliders com o volume atual dos buses (convertendo dB para linear)
	slider_musica.value = db_to_linear(AudioServer.get_bus_volume_db(bus_musica_id)) * 100
	slider_efeitos.value = db_to_linear(AudioServer.get_bus_volume_db(bus_efeitos_id)) * 100

func _on_btn_jogar_pressed():
	# 1. Limpa a memória do Global
	Global.resetar_progresso_total()
	# Direciona para a introdução em Cordel
	get_tree().change_scene_to_file("res://scenes/ui/cordel_fase_1.tscn")

func _on_btn_opcoes_pressed():
	menu_buttons.visible = false
	opcoes_panel.visible = true

func _on_btn_voltar_opcoes_pressed():
	opcoes_panel.visible = false
	menu_buttons.visible = true

func _on_btn_creditos_pressed():
	print("Abrindo créditos...")
	# get_tree().change_scene_to_file("res://cenas/Creditos.tscn")

func _on_btn_sair_pressed():
	get_tree().quit()

func _on_slider_musica_changed(value):
	# Converte o valor de 0-100 para 0.0-1.0, e depois converte para Decibéis
	AudioServer.set_bus_volume_db(bus_musica_id, linear_to_db(value / 100.0))

func _on_slider_efeitos_changed(value):
	AudioServer.set_bus_volume_db(bus_efeitos_id, linear_to_db(value / 100.0))
