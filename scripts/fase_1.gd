extends Node2D
class_name Fase1
static var pular_intro_proxima_vez: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")
@export var total_ondas: int = 5

var game_over_iniciado: bool = false
var pontuacao: int = 0
var onda_atual: int = 1
var inimigos_por_onda: int = 1
var inimigos_restantes_na_tela: int = 0
var inimigos_spawnados_na_onda: int = 0

@onready var timer_spawn = $Gameplay/TimerSpawn
@onready var gameplay = $Gameplay
@onready var ui = $UI
@onready var hud = $HUD
@onready var texto_fase = $UI/TextoFase
@onready var caixa_dialogo = $UI/CaixaDialogo
@onready var nome_personagem = $UI/CaixaDialogo/NomePersonagem
@onready var texto_fala = $UI/CaixaDialogo/TextoFala
@onready var retrato_jogador = $UI/CaixaDialogo/RetratoJogador
@onready var retrato_inimigo = $UI/CaixaDialogo/RetratoInimigo
@onready var musica_fase = $MusicaFase

var cena_saci = preload("res://scenes/entities/saci.tscn")
var estado_fase = "ANIMACAO_TEXTO" 

var dialogos = [
	{
		"nome": "Capitão Zé Galáxia", 
		"texto": "Base Canudos, cheguei na órbita. Mas o que é isso... um moleque de uma perna só atirando pipoca?",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Saci Alienígena", 
		"texto": "Krrk... Zzt... O folclore de vocês será a sua ruína, terráqueo!",
		"imagem": preload("res://assets/sprites/enemies/retrato_saci.png")
	},
	{
		"nome": "Capitão Zé Galáxia", 
		"texto": "Vai ter que pular muito para desviar dos meus foguetes. Preparar para o combate!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	}
]
var indice_dialogo = 0

func _ready():
	Global.salvar_checkpoint_sucata()
	# 1. Configurações Iniciais de nós
	gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	caixa_dialogo.visible = false
	
	# 2. Inicializa o HUD de ondas
	if hud and hud.has_method("atualizar_onda"):
		hud.atualizar_onda(onda_atual, total_ondas)
	
	# 3. Conecta o Timer de Spawn
	timer_spawn.timeout.connect(_on_timer_spawn_timeout)
	
	# 4. LÓGICA DE INÍCIO (Único Check)
	if pular_intro_proxima_vez:
		pular_intro_proxima_vez = false # Reseta para a próxima vez
		texto_fase.visible = false      # Garante que o letreiro não apareça
		encerrar_dialogo_e_iniciar_jogo() # Vai direto para o combate
	else:
		animar_texto_fase() # Inicia normal com animação e história
func iniciar_game_over():
	# Se a trava estiver ativa, ignora o resto da função
	if game_over_iniciado:
		return
	
	# Ativa a trava agora!
	game_over_iniciado = true
	
	if musica_fase: 
		musica_fase.stop()
	
	# Espera os 2 segundos de drama da explosão
	await get_tree().create_timer(2.0).timeout
	
	# PAUSA O JOGO
	get_tree().paused = true
	
	# Mostra a tela de Game Over
	var tela_death = cena_game_over.instantiate()
	add_child(tela_death)
func adicionar_pontos(quantidade: int):
	pontuacao += quantidade
	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(pontuacao)
		
func animar_texto_fase():
	var largura_tela = get_viewport_rect().size.x
	texto_fase.position.x = largura_tela
	texto_fase.position.y = 100 
	var altura_tela = get_viewport_rect().size.y
	if global_position.y > altura_tela + 100: # 100px de margem de segurança
		queue_free()
	var tween = create_tween()
	tween.tween_property(texto_fase, "position:x", (largura_tela / 2.0) - (texto_fase.size.x / 2.0), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(1.0)
	tween.tween_property(texto_fase, "position:x", -texto_fase.size.x - 50, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(iniciar_dialogos)

func iniciar_dialogos():
	estado_fase = "DIALOGO"
	caixa_dialogo.visible = true
	exibir_linha_dialogo()

func exibir_linha_dialogo():
	var fala_atual = dialogos[indice_dialogo]
	nome_personagem.text = fala_atual["nome"]
	texto_fala.text = fala_atual["texto"]
	
	if fala_atual["nome"] == "Capitão Zé Galáxia":
		retrato_jogador.texture = fala_atual["imagem"]
		retrato_jogador.visible = true
		retrato_inimigo.visible = false
	else:
		retrato_inimigo.texture = fala_atual["imagem"]
		retrato_inimigo.visible = true
		retrato_jogador.visible = false

func _input(event):
	if estado_fase == "DIALOGO" and event.is_action_pressed("ui_accept"):
		indice_dialogo += 1
		if indice_dialogo < dialogos.size():
			exibir_linha_dialogo()
		else:
			encerrar_dialogo_e_iniciar_jogo()

func encerrar_dialogo_e_iniciar_jogo():
	estado_fase = "JOGANDO"
	caixa_dialogo.visible = false
	gameplay.process_mode = Node.PROCESS_MODE_INHERIT
	
	timer_spawn.start()
	
	print("Gameplay Iniciado!")

# --- LÓGICA DO SISTEMA DE ONDAS ---

func _on_timer_spawn_timeout():
	if inimigos_spawnados_na_onda < inimigos_por_onda:
		spawnar_saci()
	else:
		timer_spawn.stop() # Para de criar inimigos até a próxima onda

func spawnar_saci():
	var saci = cena_saci.instantiate()
	
	# Posição X aleatória baseada na largura da tela (ex: 960px)
	var largura_tela = get_viewport_rect().size.x
	var x_aleatorio = randf_range(50, largura_tela - 50)
	saci.global_position = Vector2(x_aleatorio, -50) # Começa um pouco acima da tela
	
	# Conecta o sinal para saber quando o Saci sumir/morrer
	saci.tree_exited.connect(_on_saci_saiu_da_cena)
	
	gameplay.add_child(saci)
	inimigos_spawnados_na_onda += 1
	inimigos_restantes_na_tela += 1

func _on_saci_saiu_da_cena():
	inimigos_restantes_na_tela -= 1
	
	# Verifica se a onda acabou (todos spawnados e todos mortos/fora da tela)
	if inimigos_restantes_na_tela <= 0 and inimigos_spawnados_na_onda >= inimigos_por_onda:
		preparar_proxima_onda()

func preparar_proxima_onda():
	# TRAVA DE SEGURANÇA: Só continua se o nó ainda estiver na árvore
	if not is_inside_tree(): 
		return

	if onda_atual < total_ondas:
		onda_atual += 1
		inimigos_por_onda += 1 
		inimigos_spawnados_na_onda = 0
		
		if hud and hud.has_method("atualizar_onda"):
			hud.atualizar_onda(onda_atual, total_ondas)
		
		print("Iniciando Onda: ", onda_atual)
		
		# Outra trava aqui para o timer
		var timer = get_tree().create_timer(3.0)
		if timer:
			await timer.timeout
			if is_inside_tree(): # Verifica de novo após o tempo passar
				timer_spawn.start()
	else:
		vitoria()

func vitoria():
	Fase1.pular_intro_proxima_vez = false
	await get_tree().create_timer(2.0).timeout
	estado_fase = "VITORIA"
	get_tree().paused = true # Para tudo
	var tela = preload("res://scenes/ui/vitoria.tscn").instantiate()
	add_child(tela)
