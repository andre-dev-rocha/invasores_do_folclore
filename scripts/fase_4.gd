extends Node2D
class_name Fase4
static var pular_intro_fase4: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")
@export var total_ondas: int = 5

var game_over_iniciado: bool = false

var onda_atual: int = 1
var inimigos_por_onda: int = 2
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

var cena_mula = preload("res://scenes/entities/mula_sem_cabeca.tscn")
var cena_ammo = preload("res://scenes/entities/ammo_pack.tscn")
var timer_ammo: Timer
var estado_fase = "ANIMACAO_TEXTO"

var dialogos = [
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Que barulho é esse? Parece o galope de mil cavalos atravessando as galáxias!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Mula Sem Cabeça",
		"texto": "[ESTRONDO DE CHAMAS] HNGRRRR!!! Você ousou cruzar meu setor do cosmos?!",
		"imagem": preload("res://assets/sprites/enemies/retrato_mula.png")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Uma égua de fogo sem cabeça... isso explica o rastro de chamas no mapa estelar!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Mula Sem Cabeça",
		"texto": "[GALOPE TROVEJANTE] Prepare-se para sentir a fúria do meu fogo cósmico!",
		"imagem": preload("res://assets/sprites/enemies/retrato_mula.png")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Não há espaço neste universo para você assustar mais ninguém. Turbinas ao máximo!",
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

	if pular_intro_fase4:
		pular_intro_fase4 = false
		texto_fase.visible = false
		encerrar_dialogo_e_iniciar_jogo()
	else:
		animar_texto_fase()

func iniciar_game_over():
	if game_over_iniciado:
		return
	game_over_iniciado = true
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
	print("Fase 4 Iniciada!")

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
		spawnar_mula()
	else:
		timer_spawn.stop()

func spawnar_mula():
	var mula = cena_mula.instantiate()
	var largura_tela = 960
	var margem_fora = 120
	
	# NOVO: Limites de altura para a Mula
	# 80 pixels afasta ela do topo, 250 pixels mantém ela na metade superior
	var limite_superior_y = 80
	var limite_inferior_y = 250

	var lado = randi() % 2
	var pos_inicial = Vector2.ZERO
	var direcao_alvo = Vector2.ZERO

	match lado:
		0:
			# Nasce na esquerda
			pos_inicial = Vector2(-margem_fora, randf_range(limite_superior_y, limite_inferior_y))
			direcao_alvo = Vector2.RIGHT
		1:
			# Nasce na direita
			pos_inicial = Vector2(largura_tela + margem_fora, randf_range(limite_superior_y, limite_inferior_y))
			direcao_alvo = Vector2.LEFT

	mula.global_position = pos_inicial
	if mula.has_method("configurar_direcao"):
		mula.configurar_direcao(direcao_alvo)

	mula.tree_exited.connect(_on_inimigo_saiu_da_cena)
	gameplay.add_child(mula)

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
		inimigos_por_onda += 1
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
	Fase4.pular_intro_fase4 = false
	Vitoria.proxima_cena = "res://scenes/ui/loja_upgrades.tscn"
	await get_tree().create_timer(2.0).timeout
	estado_fase = "VITORIA"
	get_tree().paused = true
	var tela = preload("res://scenes/ui/vitoria.tscn").instantiate()
	add_child(tela)
