extends Control

# --- REFERÊNCIAS DOS BOTÕES ---
@onready var btn_creditos = $BotoesRodape/BtnCreditos
@onready var btn_menu = $BotoesRodape/BtnMenu

# Referências dos Labels de Valor (Certifique-se de que os caminhos estão corretos)
@onready var label_pontos = $VBoxContainer/LinhaPontos/Valor
@onready var label_tempo = $VBoxContainer/LinhaTempo/Valor
@onready var label_vidas = $VBoxContainer/LinhaVidas/Valor
@onready var label_precisao = $VBoxContainer/LinhaPrecisao/Valor
@onready var label_sucatas = $VBoxContainer/LinhaSucatas/Valor
@onready var label_melhorias = $VBoxContainer/LinhaMelhorias/Valor

# Labels de Inimigos (use nomes compatíveis com o dicionário Global)
@onready var label_saci = $VBoxContainer2/LinhaSaci/Valor
@onready var label_boto = $VBoxContainer2/LinhaBoto/Valor
@onready var label_cuca = $VBoxContainer2/LinhaCuca/Valor
@onready var label_mula = $VBoxContainer2/LinhaMula/Valor
@onready var label_papao = $VBoxContainer2/LinhaPapao/Valor

func _ready():

	_preencher_dados()
# --- CONECTANDO OS BOTÕES VIA CÓDIGO ---
	if btn_creditos:
		btn_creditos.pressed.connect(_on_btn_creditos_pressed)
		
	if btn_menu:
		btn_menu.pressed.connect(_on_btn_menu_pressed)
		

func _preencher_dados():
	# 1. Dados Básicos
	label_pontos.text = str(Global.pontuacao_total)
	label_sucatas.text = str(Global.sucatas_totais_coletadas)
	label_vidas.text = str(Global.vidas_totais_perdidas)
	
	# 2. Formata o Tempo (Segundos para MM:SS)
	var tempo_seg = Global.tempo_total_jogo
	var minutos = int(tempo_seg / 60)
	var segundos = int(tempo_seg) % 60
	label_tempo.text = "%02d:%02d" % [minutos, segundos]
	
	# 3. Calcula Precisão
	if Global.total_tiros_disparados > 0:
		var precisao = (float(Global.total_tiros_acertados) / Global.total_tiros_disparados) * 100.0
		label_precisao.text = "%.1f%%" % precisao
	else:
		label_precisao.text = "0.0%"
		
	# 4. Total de Melhorias Compradas (Soma dos níveis)
	var total_melhorias = Global.nivel_cadencia + Global.nivel_resistencia + Global.nivel_velocidade + Global.nivel_escudo
	label_melhorias.text = str(total_melhorias)

	# 5. Preenche Inimigos Específicos do Dicionário
	label_saci.text = str(Global.inimigos_derrotados["Saci"])
	label_boto.text = str(Global.inimigos_derrotados["Boto"])
	label_cuca.text = str(Global.inimigos_derrotados["Cuca"])
	label_mula.text = str(Global.inimigos_derrotados["Mula"])
	label_papao.text = str(Global.inimigos_derrotados["BichoPapao"])

# --- FUNÇÕES DOS BOTÕES ---

func _on_btn_creditos_pressed():
	get_tree().paused = false
	# Mude para a cena de créditos que você já possui
	get_tree().change_scene_to_file("res://scenes/ui/creditos.tscn")

func _on_btn_menu_pressed():
	get_tree().paused = false
	Global.resetar_progresso_total() # Importante resetar ao voltar pro menu
	# Mude para a cena do seu menu principal
	get_tree().change_scene_to_file("res://scenes/ui/menu_principal.tscn")
