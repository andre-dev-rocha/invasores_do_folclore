extends Control

# Custos progressivos para cada nível
var custos = [20, 50, 100]
var tex_vazio = preload("res://assets/backgrounds/circulo_upgrade.png")
var tex_cheio = preload("res://assets/backgrounds/circulo_upgrade_preenchido.png")
@onready var lista_upgrades = $MenuLateral/ListaUpgrades
@onready var label_saldo_sucata = $MenuLateral/SaldoSucataLabel
func _ready():
	atualizar_interface_completa()

func atualizar_interface_completa():
	label_saldo_sucata.text = "Sucatas: " + str(Global.total_sucatas)
	atualizar_linha("LinhaCadencia", Global.nivel_cadencia)
	atualizar_linha("LinhaDurabilidade", Global.nivel_resistencia)
	atualizar_linha("LinhaVelocidade", Global.nivel_velocidade)
	atualizar_linha("LinhaEscudo", Global.nivel_escudo)

func atualizar_linha(nome_linha: String, nivel_atual: int):
	var linha = lista_upgrades.get_node(nome_linha)
	var hbox_circulos = linha.get_node("InfoVBox/HBoxContainer")
	var label_preco = linha.get_node("InfoVBox/PreçoLabel")
	
	for i in range(1, 4):
		var circulo = hbox_circulos.get_node("C" + str(i))
		
		if i <= nivel_atual:
			# Troca para a imagem preenchida e pinta de verde
			circulo.texture = tex_cheio
			circulo.modulate = Color(1, 1, 1) # Verde Neon
		else:
			# Volta para a imagem de contorno e deixa cinza/branco
			circulo.texture = tex_vazio
			circulo.modulate = Color(1, 1, 1,) # Branco com 50% de transparência

	# Atualiza preço e botão (conforme código anterior)
	if nivel_atual < 3:
		label_preco.text = "Custo: " + str(custos[nivel_atual]) + " sucatas"
	else:
		label_preco.text = "MÁXIMO"
		hbox_circulos.get_node("UpgradeBtn").disabled = true
# --- FUNÇÕES DE CLIQUE (Conecte estas funções na aba "Nó" dos seus botões) ---

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
func _on_btn_iniciar_missao_pressed():
	# Esta função decide para qual história de cordel o jogador vai
	Global.ir_para_proxima_historia()
