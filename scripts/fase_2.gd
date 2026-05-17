extends Node2D
class_name Fase2
static var pular_intro_fase2: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")
var cena_vitoria = preload("res://scenes/ui/vitoria.tscn")
@export var total_ondas: int = 5

var game_over_iniciado: bool = false

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

var cena_boto = preload("res://scenes/entities/boto.tscn")
var estado_fase = "ANIMACAO_TEXTO" 

var dialogos = [
	{
		"nome": "Capitão Zé Galáxia", 
		"texto": "Apareça, malandro das águas! Meus sensores detectam um rastro de... perfume e energia rosa?",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Boto-Cor-De-Rosa", 
		"texto": "Ora, Capitão, por que tanta pressa? Venha dançar nesta nebulosa, a festa está apenas começando!",
		"imagem": preload("res://assets/sprites/enemies/retrato_boto.png")
	},
	{
		"nome": "Capitão Zé Galáxia", 
		"texto": "Já conheço sua fama, Boto. Você encanta para depois roubar a energia da nave. Não cairei no seu papo!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Boto-Cor-De-Rosa", 
		"texto": "Que rude! Se não quer dançar, então prepare-se para o mergulho... nas profundezas do esquecimento!",
		"imagem": preload("res://assets/sprites/enemies/retrato_boto.png")
	},
	{
		"nome": "Capitão Zé Galáxia", 
		"texto": "Minhas turbinas estão prontas. Vamos ver se você é tão bom de mira quanto é de conversa!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	}
]
var indice_dialogo = 0

func _ready():
	Global.salvar_checkpoint_fase()
	# 1. Configurações Iniciais de nós
	gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	caixa_dialogo.visible = false

	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(Global.pontuacao_total)
	# 2. Inicializa o HUD de ondas
	if hud and hud.has_method("atualizar_onda"):
		hud.atualizar_onda(onda_atual, total_ondas)
	
	# 3. Conecta o Timer de Spawn
	timer_spawn.timeout.connect(_on_timer_spawn_timeout)
	
	# 4. LÓGICA DE INÍCIO (Único Check)
	if pular_intro_fase2:
		pular_intro_fase2 = false # Reseta para a próxima vez
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
	
	Global.pontuacao_total += quantidade
	
	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(Global.pontuacao_total)

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

# --- LÓGICA DO SISTEMA DE ONDAS ADAPTADA ---

func _on_timer_spawn_timeout():
	if inimigos_spawnados_na_onda < inimigos_por_onda:
		spawnar_boto()
	else:
		timer_spawn.stop()

func spawnar_boto():
	var boto = cena_boto.instantiate()
	var largura_tela = 960
	var altura_tela = 720
	var margem_seguranca = 250 # Distância que você pediu
	var margem_fora = 100 # Para surgir fora da visão
	
	var lado = randi() % 4
	var pos_inicial = Vector2.ZERO
	var direcao_alvo = Vector2.ZERO

	match lado:
		0: # Topo -> Para baixo
			pos_inicial = Vector2(randf_range(100, largura_tela - 100), -margem_fora)
			direcao_alvo = Vector2.DOWN
		1: # Baixo -> Para cima
			pos_inicial = Vector2(randf_range(100, largura_tela - 100), altura_tela + margem_fora)
			direcao_alvo = Vector2.UP
		2: # Esquerda -> Para direita
			# Aqui aplicamos a sua restrição de 250px de distância do topo/baixo
			pos_inicial = Vector2(-margem_fora, randf_range(margem_seguranca, altura_tela - margem_seguranca))
			direcao_alvo = Vector2.RIGHT
		3: # Direita -> Para esquerda
			# Aqui aplicamos a sua restrição de 250px de distância do topo/baixo
			pos_inicial = Vector2(largura_tela + margem_fora, randf_range(margem_seguranca, altura_tela - margem_seguranca))
			direcao_alvo = Vector2.LEFT

	boto.global_position = pos_inicial
	if boto.has_method("configurar_direcao"):
		boto.configurar_direcao(direcao_alvo)
	
	boto.tree_exited.connect(_on_inimigo_saiu_da_cena)
	gameplay.add_child(boto)
	
	inimigos_spawnados_na_onda += 1
	inimigos_restantes_na_tela += 1

func _on_inimigo_saiu_da_cena():
	inimigos_restantes_na_tela -= 1
	if inimigos_restantes_na_tela <= 0 and inimigos_spawnados_na_onda >= inimigos_por_onda:
		preparar_proxima_onda()

func preparar_proxima_onda():
	if not is_inside_tree(): return

	if onda_atual < total_ondas:
		onda_atual += 1
		inimigos_por_onda += 2 # Adiciona 2 boto a cada onda
		inimigos_spawnados_na_onda = 1
		
		if hud and hud.has_method("atualizar_onda"):
			hud.atualizar_onda(onda_atual, total_ondas)
		
		var timer = get_tree().create_timer(3.0)
		await timer.timeout
		if is_inside_tree():
			timer_spawn.start()
	else:
		vitoria()

func vitoria():
	Fase2.pular_intro_fase2 = false
	await get_tree().create_timer(2.0).timeout
	estado_fase = "VITORIA"
	get_tree().paused = true # Para tudo
	var tela = preload("res://scenes/ui/vitoria.tscn").instantiate()
	add_child(tela)
