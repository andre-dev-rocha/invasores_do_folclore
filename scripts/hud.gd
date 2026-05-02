extends CanvasLayer

@onready var container_vidas = $ContainerVidas
@onready var label_pontos = $LabelPontos
@onready var label_onda = $LabelOnda
@onready var barra_escudo = $BarraEscudo
@onready var label_municao = $LabelMunicao
@onready var label_sucata = $LabelSucata

func atualizar_pontos(valor: int):
	if label_pontos:
		label_pontos.text = "Pontos: " + str(valor).pad_zeros(4)

func atualizar_onda(atual: int, total: int):
	if label_onda:
		label_onda.text = "Onda " + str(atual) + "/" + str(total) 

func atualizar_vidas(quantidade: int):
	# PROTEÇÃO: Verifica se o container existe antes de pedir os filhos
	if container_vidas == null:
		print("AVISO: Nó 'ContainerVidas' não encontrado no HUD!")
		return
		
	var coracoes = container_vidas.get_children()
	
	for i in range(coracoes.size()):
		# Mostra o coração se o índice for menor que a vida atual
		coracoes[i].visible = i < quantidade

func atualizar_barra_escudo(porcentagem: float):
	if barra_escudo:
		barra_escudo.value = porcentagem
	
func atualizar_municao(valor: int):
	if label_municao:
		label_municao.text = "Munição: " + str(valor)
		
		# Efeito visual: muda a cor para vermelho se estiver acabando
		if valor < 20:
			label_municao.modulate = Color.RED
		else:
			label_municao.modulate = Color.WHITE

func atualizar_sucata(valor: int):
	if label_sucata:
		label_sucata.text = "Sucatas: " + str(valor)
