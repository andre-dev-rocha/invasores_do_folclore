extends Node2D
class_name Fase5

static var pular_intro_fase5: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")

var game_over_iniciado: bool = false
var estado_fase = "ANIMACAO_TEXTO"
var cena_ammo = preload("res://scenes/entities/ammo_pack.tscn")
var timer_ammo: Timer

@onready var barra_vida_boss = $UI/BarraVidaBoss
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

# PEGA A REFERÊNCIA DO CHEFE QUE VOCÊ COLOCOU NA CENA
@onready var boss = $Gameplay/BichoPapao 

# --- DIÁLOGOS DA BATALHA FINAL ---
var dialogos = [
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "A Mula Sem Cabeça já era... mas o que é essa aura sombria? Meus radares estão congelando!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Bicho-Papão",
		"texto": "[VOZ GUTURAL] Você apagou minhas chamas e dissipou minha névoa... mas não pode fugir da escuridão absoluta.",
		"imagem": preload("res://assets/sprites/enemies/retrato_bicho_papao.png")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Então você é o mandante de tudo isso! O Bicho-Papão em pessoa! Veio assustar o sistema solar errado!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Bicho-Papão",
		"texto": "Eu sou o devorador de estrelas! O fim do seu cordel! A luz da sua nave será a próxima a se apagar.",
		"imagem": preload("res://assets/sprites/enemies/retrato_bicho_papao.png")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Meu cordel só termina quando a galáxia estiver a salvo! Engole laser, assombração cibernética!",
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
	# Esconde "Ondas" do HUD
	if hud and hud.has_node("LabelOnda"):
		hud.get_node("LabelOnda").visible = false

	# CONECTA O SINAL DO CHEFE JÁ EXISTENTE
	if boss and boss.has_signal("derrotado"):
		boss.derrotado.connect(vitoria_final)

	if boss:
			if boss.has_signal("derrotado") and not boss.derrotado.is_connected(vitoria_final):
				boss.derrotado.connect(vitoria_final)
				
			if boss.has_signal("hp_alterado") and not boss.hp_alterado.is_connected(_atualizar_barra_vida_boss):
				boss.hp_alterado.connect(_atualizar_barra_vida_boss)
				
			# Configura o valor inicial da barra
			barra_vida_boss.max_value = boss.hp_maximo
			barra_vida_boss.value = boss.hp_maximo
	if pular_intro_fase5:
		pular_intro_fase5 = false
		texto_fase.visible = false
		encerrar_dialogo_e_iniciar_jogo()
	else:
		texto_fase.text = "ALERTA: CHEFE FINAL!"
		texto_fase.modulate = Color.RED
		animar_texto_fase()

func iniciar_game_over():
	if game_over_iniciado:
		return
	game_over_iniciado = true
	Fase5.pular_intro_fase5 = true 
	
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
	texto_fase.position.y = get_viewport_rect().size.y / 2.0 - 50
	var tween = create_tween()
	tween.tween_property(texto_fase, "position:x", (largura_tela / 2.0) - (texto_fase.size.x / 2.0), 2.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(texto_fase, "position:x", -texto_fase.size.x - 50, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
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

func iniciar_spawn_ammo():
	timer_ammo = Timer.new()
	timer_ammo.wait_time = 5.0
	timer_ammo.timeout.connect(spawnar_ammo)
	add_child(timer_ammo)
	timer_ammo.start()

func spawnar_ammo():
	var ammo = cena_ammo.instantiate()
	ammo.global_position = Vector2(randf_range(60, 900), -40)
	gameplay.add_child(ammo)

func encerrar_dialogo_e_iniciar_jogo():
	estado_fase = "JOGANDO"
	caixa_dialogo.visible = false
	barra_vida_boss.visible = true
	# Ao devolver o process_mode, o Bicho-Papão "acorda" automaticamente!
	gameplay.process_mode = Node.PROCESS_MODE_INHERIT
	iniciar_spawn_ammo()
	print("Batalha Final Iniciada!")

func _atualizar_barra_vida_boss(hp_atual: float):
	if is_instance_valid(barra_vida_boss):
		# Cria um tween rápido para a barra descer suavemente (efeito visual bacana)
		var tween = create_tween()
		tween.tween_property(barra_vida_boss, "value", hp_atual, 0.2).set_trans(Tween.TRANS_SINE)
		
func vitoria_final():
	if not is_inside_tree(): return
	if game_over_iniciado: return 
	if estado_fase == "VITORIA": return

	estado_fase = "VITORIA"
	if barra_vida_boss:
		barra_vida_boss.visible = false
	
	if musica_fase:
		musica_fase.stop()
		
	# Finaliza a contagem de tempo do jogo
	Global.finalizar_jogo()
		
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	
	if not is_inside_tree(): return
	
	# IMPORTANTE: Despausar antes de mudar de cena para os botões funcionarem depois
	get_tree().paused = false 
	
	# MUDA DE CENA EM VEZ DE SOBREPOR
	get_tree().change_scene_to_file("res://scenes/ui/cordel_fase_6.tscn")
