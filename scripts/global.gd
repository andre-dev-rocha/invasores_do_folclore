extends Node

var sucatas_totais_coletadas: int = 0
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

# Estatísticas para tela pós-jogo:

var tempo_inicio_jogo: float = 0.0
var tempo_total_jogo: float = 0.0
var vidas_totais_perdidas: int = 0
var total_tiros_disparados: int = 0
var total_tiros_acertados: int = 0

var inimigos_derrotados = {
	"Saci": 0,
	"Boto": 0,
	"Cuca": 0,
	"Mula": 0,
	"BichoPapao": 0
}

func iniciar_novo_jogo():
	resetar_progresso_total()
	tempo_inicio_jogo = Time.get_unix_time_from_system()
	vidas_totais_perdidas = 0
	total_tiros_disparados = 0
	total_tiros_acertados = 0
	for key in inimigos_derrotados.keys():
		inimigos_derrotados[key] = 0

# Chamado quando o Bicho Papão é derrotado
func finalizar_jogo():
	var tempo_fim = Time.get_unix_time_from_system()
	
	# Se o tempo for 0, significa que você testou a fase direto pelo editor (F6)
	if tempo_inicio_jogo == 0.0:
		# Usa o tempo de atividade da Godot (em segundos)
		tempo_total_jogo = Time.get_ticks_msec() / 1000.0 
	else:
		tempo_total_jogo = tempo_fim - tempo_inicio_jogo

# Chamado nos scripts dos inimigos (Saci, Cuca, etc.) quando morrem
func registrar_morte_inimigo(nome_inimigo: String):
	if inimigos_derrotados.has(nome_inimigo):
		inimigos_derrotados[nome_inimigo] += 1
		print("Inimigo ", nome_inimigo, " derrotado! Total: ", inimigos_derrotados[nome_inimigo])

# Chamado no script do Player quando perder uma vida
func registrar_vida_perdida():
	vidas_totais_perdidas += 1

# Chamado no script do Player quando atirar
func registrar_tiro_disparado():
	total_tiros_disparados += 1

# Chamado no script do Projétil quando acertar um inimigo
func registrar_tiro_acertado():
	total_tiros_acertados += 1
	
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
	sucatas_totais_coletadas = 0
	# Reseta os níveis de upgrade
	nivel_cadencia = 0
	nivel_resistencia = 0
	nivel_velocidade = 0
	nivel_escudo = 0
	
	print("Progresso total resetado para um Novo Jogo!")
