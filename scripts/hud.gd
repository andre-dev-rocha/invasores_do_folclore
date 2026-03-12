extends CanvasLayer

@onready var container_vidas = $ContainerVidas
@onready var label_pontos = $LabelPontos
@onready var label_onda = $LabelOnda
@onready var barra_escudo = $BarraEscudo

func atualizar_pontos(valor: int):
	# O str() converte o número em texto para o Label
	label_pontos.text = "Pontos: " + str(valor).pad_zeros(4)
func atualizar_onda(atual: int, total: int):
	label_onda.text = "Onda " + str(atual) + "/" + str(total) 

func atualizar_vidas(quantidade: int):
	# Mostra apenas o número de corações equivalente às vidas restantes [cite: 140]
	var coracoes = container_vidas.get_children()
	for i in range(coracoes.size()):
		coracoes[i].visible = i < quantidade

func atualizar_barra_escudo(porcentagem: float):
	barra_escudo.value = porcentagem 
