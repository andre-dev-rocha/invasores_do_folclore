extends Node2D
class_name Fase3

static var pular_intro_fase3: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")
@export var total_ondas: int = 5

var game_over_iniciado: bool = false

var onda_atual: int = 1
var inimigos_por_onda: int = 2 # Começa com 6 Cucas
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

# --- CARREGA A CENA DA CUCA AQUI ---
var cena_cuca = preload("res://scenes/entities/cuca.tscn")
var cena_ammo = preload("res://scenes/entities/ammo_pack.tscn")
var timer_ammo: Timer
var estado_fase = "ANIMACAO_TEXTO"

# --- DIÁLOGOS DA FASE 3 ---
var dialogos = [
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Essa névoa verde... Meus radares estão enlouquecendo! O que é isso no painel?",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Cuca Sideral",
		"texto": "[RISADA MALÉFICA] Jacaré no espaço? Não, seu tolo. É a Cuca Sideral!",
		"imagem": preload("res://assets/sprites/enemies/retrato_cuca.png") # CRIE/ATUALIZE ESSE RETRATO!
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Aquele caldeirão está radioativo! O que você está cozinhando aí, bruxa?",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Cuca Sideral",
		"texto": "O fim da sua jornada, Zé Galáxia! Prove da minha magia verde e apodreça no vácuo!",
		"imagem": preload("res://assets/sprites/enemies/retrato_cuca.png")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Prepara as escamas, Cuca! Meus lasers estão quentes e prontos pro abate!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	}
]
var indice_dialogo = 0

func _ready():
	Global.salvar_checkpoint_fase()
	gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	caixa_dialogo.visible = false

	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(Global.pontuacao_total)
	if hud and hud.has_method("atualizar_onda"):
		hud.atualizar_onda(onda_atual, total_ondas)

	timer_spawn.timeout.connect(_on_timer_spawn_timeout)

	if pular_intro_fase3:
		pular_intro_fase3 = false
		texto_fase.visible = false
		encerrar_dialogo_e_iniciar_jogo()
	else:
		animar_texto_fase()

func iniciar_game_over():
	if game_over_iniciado:
		return
	game_over_iniciado = true
	
	# --- A CORREÇÃO ESTÁ AQUI ---
	# Avisa ao jogo para pular a intro na próxima vez que a cena carregar
	Fase3.pular_intro_fase3 = true 
	
	if musica_fase:
		musica_fase.stop()
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = true
	var tela_death = cena_game_over.instantiate()
	add_child(tela_death)
func adicionar_pontos(quantidade: int):
	# Soma diretamente na variável global persistente
	Global.pontuacao_total += quantidade
	
	# Atualiza o HUD com o valor global
	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(Global.pontuacao_total)
func animar_texto_fase():
	var largura_tela = get_viewport_rect().size.x
	texto_fase.position.x = largura_tela
	texto_fase.position.y = 100
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
	iniciar_spawn_ammo()
	print("Fase 3 Iniciada!")

func iniciar_spawn_ammo():
	timer_ammo = Timer.new()
	timer_ammo.wait_time = 10.0
	timer_ammo.timeout.connect(spawnar_ammo)
	add_child(timer_ammo)
	timer_ammo.start()

func spawnar_ammo():
	var ammo = cena_ammo.instantiate()
	ammo.global_position = Vector2(randf_range(60, 900), -40)
	gameplay.add_child(ammo)

func _on_timer_spawn_timeout():
	if inimigos_spawnados_na_onda < inimigos_por_onda:
		spawnar_inimigo_cuca()
	else:
		timer_spawn.stop()

# --- NOVA LÓGICA DE SPAWN PARA A CUCA ---
func spawnar_inimigo_cuca():
	var cuca_inst = cena_cuca.instantiate()
	
	var margem_seguranca = 80
	var limite_direito = get_viewport_rect().size.x - margem_seguranca
	
	# Nasce em uma posição X aleatória no topo da tela (fora da visão)
	var pos_x = randf_range(margem_seguranca, limite_direito)
	var pos_inicial = Vector2(pos_x, -100) # -100 para nascer acima da tela
	
	cuca_inst.global_position = pos_inicial
	
	# Diz para ela descer
	if cuca_inst.has_method("configurar_direcao"):
		cuca_inst.configurar_direcao(Vector2.DOWN)

	cuca_inst.tree_exited.connect(_on_inimigo_saiu_da_cena)
	gameplay.add_child(cuca_inst)

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
		inimigos_por_onda += 2 # Aumenta a dificuldade a cada onda
		inimigos_spawnados_na_onda = 0

		if hud and hud.has_method("atualizar_onda"):
			hud.atualizar_onda(onda_atual, total_ondas)

		var timer = get_tree().create_timer(3.0)
		await timer.timeout
		if is_inside_tree():
			timer_spawn.start()
	else:
		vitoria()

func vitoria():
	Fase3.pular_intro_fase3 = false
	Vitoria.proxima_cena = "res://scenes/ui/loja_upgrades.tscn" # Ou mande para o Cordel, dependendo do seu fluxo!
	await get_tree().create_timer(2.0).timeout
	estado_fase = "VITORIA"
	get_tree().paused = true
	var tela = preload("res://scenes/ui/vitoria.tscn").instantiate()
	add_child(tela)
