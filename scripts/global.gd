extends Node

var total_sucatas: int = 0
var sucatas_no_inicio_da_fase: int = 0
var fase_atual: int = 1


var pontuacao_total: int = 0
var pontuacao_no_inicio_da_fase: int = 0

# Níveis de upgrade (0 a 3)
var nivel_cadencia: int = 0
var nivel_resistencia: int = 0
var nivel_velocidade: int = 0
var nivel_escudo: int = 0

# Valores Base
var base_cadencia: float = 0.4
var base_vidas: int = 3
var base_velocidade: float = 400.0
var base_escudo: float = 7.0


# Chamado sempre que uma fase começa (Salva Sucata e Pontuação)
func salvar_checkpoint_fase():
	sucatas_no_inicio_da_fase = total_sucatas
	pontuacao_no_inicio_da_fase = pontuacao_total
	print("Checkpoint salvo! Sucatas: ", sucatas_no_inicio_da_fase, " | Pontos: ", pontuacao_no_inicio_da_fase)

# Chamado quando o jogador clica em "Tentar Novamente" (Restaura ambos)
func restaurar_checkpoint_fase():
	total_sucatas = sucatas_no_inicio_da_fase
	pontuacao_total = pontuacao_no_inicio_da_fase
	print("Progresso restaurado para o início da fase!")

# Funções para calcular os valores reais com os bônus
func get_cadencia() -> float:
	return base_cadencia * (1.0 - (nivel_cadencia * 0.20))

func get_vidas() -> int:
	return base_vidas + nivel_resistencia

func get_velocidade() -> float:
	return base_velocidade * (1.0 + (nivel_velocidade * 0.20))

func get_duracao_escudo() -> float:
	return base_escudo + (nivel_escudo * 2.0)

func ir_para_proxima_historia():
	fase_atual += 1
	var caminho_historia = "res://scenes/ui/cordel_fase_" + str(fase_atual) + ".tscn"
	if ResourceLoader.exists(caminho_historia):
		get_tree().change_scene_to_file(caminho_historia)
	else:
		print("Fim das histórias ou arquivo não encontrado!")

func resetar_progresso_total():
	total_sucatas = 0
	sucatas_no_inicio_da_fase = 0
	fase_atual = 1
	
	# Reseta as pontuações
	pontuacao_total = 0
	pontuacao_no_inicio_da_fase = 0
	
	# Reseta os níveis de upgrade
	nivel_cadencia = 0
	nivel_resistencia = 0
	nivel_velocidade = 0
	nivel_escudo = 0
	
	print("Progresso total resetado para um Novo Jogo!")
