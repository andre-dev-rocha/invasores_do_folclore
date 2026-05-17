extends Control

# Custos progressivos para cada nível
var custos = [20, 50, 100]
var tex_vazio = preload("res://assets/backgrounds/circulo_upgrade.png")
var tex_cheio = preload("res://assets/backgrounds/circulo_upgrade_preenchido.png")

@onready var lista_upgrades = $MenuLateral/ListaUpgrades
@onready var label_saldo_sucata = $MenuLateral/SaldoSucataLabel

# VARIÁVEIS PARA MEMORIZAR O ESTADO ANTES DAS COMPRAS DESTA SALA
var nivel_inicial_cadencia: int = 0
var nivel_inicial_durabilidade: int = 0
var nivel_inicial_velocidade: int = 0
var nivel_inicial_escudo: int = 0

func _ready():
	# Armazena o nível que o jogador tinha ao entrar na sala
	nivel_inicial_cadencia = Global.nivel_cadencia
	nivel_inicial_durabilidade = Global.nivel_resistencia
	nivel_inicial_velocidade = Global.nivel_velocidade
	nivel_inicial_escudo = Global.nivel_escudo
	
	atualizar_interface_completa()

func atualizar_interface_completa():
	label_saldo_sucata.text = "Sucatas: " + str(Global.total_sucatas)
	atualizar_linha("LinhaCadencia", Global.nivel_cadencia, nivel_inicial_cadencia)
	atualizar_linha("LinhaDurabilidade", Global.nivel_resistencia, nivel_inicial_durabilidade)
	atualizar_linha("LinhaVelocidade", Global.nivel_velocidade, nivel_inicial_velocidade)
	atualizar_linha("LinhaEscudo", Global.nivel_escudo, nivel_inicial_escudo)

func atualizar_linha(nome_linha: String, nivel_atual: int, nivel_inicial: int):
	var linha = lista_upgrades.get_node(nome_linha)
	var hbox_circulos = linha.get_node("InfoVBox/HBoxContainer")
	var label_preco = linha.get_node("InfoVBox/PreçoLabel")
	
	var upgrade_btn = hbox_circulos.get_node("UpgradeBtn")
	var downgrade_btn = hbox_circulos.get_node("DowngradeBtn") # Nosso novo botão de menos
	
	# Atualiza o visual dos círculos preenchidos
	for i in range(1, 4):
		var circulo = hbox_circulos.get_node("C" + str(i))
		if i <= nivel_atual:
			circulo.texture = tex_cheio
			circulo.modulate = Color(1, 1, 1)
		else:
			circulo.texture = tex_vazio
			circulo.modulate = Color(1, 1, 1)

	# REGRA DO BOTÃO DE MENOS (-): 
	# Só fica visível se o nível atual for maior do que o nível com que o jogador entrou na sala
	if nivel_atual > nivel_inicial:
		downgrade_btn.visible = true
	else:
		downgrade_btn.visible = false

	# Atualiza preço e estado do botão de Mais (+)
	if nivel_atual < 3:
		label_preco.text = "Custo: " + str(custos[nivel_atual]) + " sucatas"
		upgrade_btn.disabled = false
	else:
		label_preco.text = "MÁXIMO"
		upgrade_btn.disabled = true

# --- FUNÇÕES DE CLIQUE PARA UPGRADE (+) ---

func _on_upgrade_cadencia():
	if Global.nivel_cadencia < 3:
		var custo = custos[Global.nivel_cadencia]
		if Global.total_sucatas >= custo:
			Global.total_sucatas -= custo
			Global.nivel_cadencia += 1
			atualizar_interface_completa()

func _on_upgrade_durabilidade():
	if Global.nivel_resistencia < 3:
		var custo = custos[Global.nivel_resistencia]
		if Global.total_sucatas >= custo:
			Global.total_sucatas -= custo
			Global.nivel_resistencia += 1
			atualizar_interface_completa()

func _on_upgrade_velocidade():
	if Global.nivel_velocidade < 3:
		var custo = custos[Global.nivel_velocidade]
		if Global.total_sucatas >= custo:
			Global.total_sucatas -= custo
			Global.nivel_velocidade += 1
			atualizar_interface_completa()
			
func _on_upgrade_escudo():
	if Global.nivel_escudo < 3:
		var custo = custos[Global.nivel_escudo]
		if Global.total_sucatas >= custo:
			Global.total_sucatas -= custo
			Global.nivel_escudo += 1
			atualizar_interface_completa()

# --- NOVAS FUNÇÕES DE CLIQUE PARA DOWNGRADE (-) ---
# Conecte-as ao sinal 'pressed' dos seus novos botões de menos

func _on_downgrade_cadencia():
	if Global.nivel_cadencia > nivel_inicial_cadencia:
		Global.nivel_cadencia -= 1
		var reembolso = custos[Global.nivel_cadencia]
		Global.total_sucatas += reembolso
		atualizar_interface_completa()

func _on_downgrade_durabilidade():
	if Global.nivel_resistencia > nivel_inicial_durabilidade:
		Global.nivel_resistencia -= 1
		var reembolso = custos[Global.nivel_resistencia]
		Global.total_sucatas += reembolso
		atualizar_interface_completa()

func _on_downgrade_velocidade():
	if Global.nivel_velocidade > nivel_inicial_velocidade:
		Global.nivel_velocidade -= 1
		var reembolso = custos[Global.nivel_velocidade]
		Global.total_sucatas += reembolso
		atualizar_interface_completa()

func _on_downgrade_escudo():
	if Global.nivel_escudo > nivel_inicial_escudo:
		Global.nivel_escudo -= 1
		var reembolso = custos[Global.nivel_escudo]
		Global.total_sucatas += reembolso
		atualizar_interface_completa()

# --- INICIAR JOGO ---
func _on_btn_iniciar_missao_pressed():
	Global.ir_para_proxima_historia()
