extends CanvasLayer

# Usando Unique Names para nunca mais errar o caminho do nó
@onready var menu_principal = %MenuPrincipal
@onready var menu_opcoes = %MenuOpcoes
@onready var menu_confirmacao = %MenuConfirmacao
@onready var slider_musica = %SliderMusica
@onready var slider_sfx = %SliderSFX

func _ready():
	# Começa tudo escondido
	visible = false
	menu_opcoes.visible = false
	menu_principal.visible = true
	
	# Sincroniza áudio (Verifique se o bus se chama "Music" ou "Musica")
	_sincronizar_audio()

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Tecla ESC
		toggle_pause()

func toggle_pause():
	var novo_estado = !get_tree().paused
	get_tree().paused = novo_estado
	visible = novo_estado
	
	# Reseta para o menu principal ao abrir
	if visible:
		menu_opcoes.visible = false
		menu_principal.visible = true
		menu_confirmacao.visible = false

func _sincronizar_audio():
	var bus_m = AudioServer.get_bus_index("Music") # Ajuste para o nome do seu Bus
	var bus_s = AudioServer.get_bus_index("SFX")
	
	if bus_m != -1:
		slider_musica.value = db_to_linear(AudioServer.get_bus_volume_db(bus_m))
	if bus_s != -1:
		slider_sfx.value = db_to_linear(AudioServer.get_bus_volume_db(bus_s))

# --- CONEXÕES DE SINAIS ---

func _on_btn_continuar_pressed():
	toggle_pause()

func _on_btn_opcoes_pressed():
	menu_principal.visible = false
	menu_opcoes.visible = true

func _on_btn_voltar_pressed():
	menu_opcoes.visible = false
	menu_principal.visible = true

func _on_btn_sair_pressed():
	menu_principal.visible = false
	menu_confirmacao.visible = true
	
func _on_btn_nao_pressed():
	# Arrependeu-se? Volta para os botões do pause
	menu_confirmacao.visible = false
	menu_principal.visible = true

func _on_btn_sim_pressed():
	# Confirmou? Sai do jogo
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/menu_principal.tscn")
func _on_slider_musica_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_slider_sfx_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
