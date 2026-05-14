extends Node

var total_sucatas: int = 0
var sucatas_no_inicio_da_fase: int = 0
var fase_atual: int = 1
# Níveis de upgrade (0 a 3)
var nivel_cadencia: int = 0
var nivel_resistencia: int = 0
var nivel_velocidade: int = 0
var nivel_escudo: int = 0

# Valores Base (os mesmos que você já usa no Player)
var base_cadencia: float = 0.4
var base_vidas: int = 3
var base_velocidade: float = 400.0
var base_escudo: float = 7.0


# Chamado sempre que uma fase começa (antes de coletar qualquer coisa)
func salvar_checkpoint_sucata():
	sucatas_no_inicio_da_fase = total_sucatas
	print("Checkpoint de sucata salvo: ", sucatas_no_inicio_da_fase)

# Chamado quando o jogador clica em "Tentar Novamente"
func restaurar_checkpoint_sucata():
	total_sucatas = sucatas_no_inicio_da_fase
	print("Sucata restaurada para o valor inicial da fase: ", total_sucatas)
# Funções para calcular os valores reais com os bônus
func get_cadencia() -> float:
	# Melhora 20% (reduz o tempo de espera) por nível
	return base_cadencia * (1.0 - (nivel_cadencia * 0.20))

func get_vidas() -> int:
	return base_vidas + nivel_resistencia

func get_velocidade() -> float:
	return base_velocidade * (1.0 + (nivel_velocidade * 0.20))

func get_duracao_escudo() -> float:
	return base_escudo + (nivel_escudo * 2.0)
func ir_para_proxima_historia():
	# Incrementa a fase após a vitória e a passagem pela loja
	fase_atual += 1
	
	# Define qual cena de cordel carregar baseada na próxima fase
	var caminho_historia = "res://scenes/ui/cordel_fase_" + str(fase_atual) + ".tscn"
	if ResourceLoader.exists(caminho_historia):
		get_tree().change_scene_to_file(caminho_historia)
	else:
		print("Fim das histórias ou arquivo não encontrado!")
		# Se não houver mais histórias, talvez ir para os créditos?
func resetar_progresso_total():
	total_sucatas = 0
	sucatas_no_inicio_da_fase = 0
	fase_atual = 1
	
	# Reseta os níveis de upgrade
	nivel_cadencia = 0
	nivel_resistencia = 0
	nivel_velocidade = 0
	nivel_escudo = 0
	
	print("Progresso total resetado para um Novo Jogo!")
