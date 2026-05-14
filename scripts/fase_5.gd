extends Node2D
class_name Fase5

static var pular_intro_fase5: bool = false
var cena_game_over = preload("res://scenes/ui/game_over.tscn")
var cena_boss = preload("res://scenes/entities/bicho_papao.tscn")

var game_over_iniciado: bool = false
var pontuacao: int = 0
var estado_fase = "ANIMACAO_TEXTO"

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
@onready var canvas_modulate = $CanvasModulate # Essencial para o poder do chefão

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
		"imagem": preload("res://assets/sprites/enemies/retrato_bicho_papao.jpeg") # Certifique-se de criar este retrato
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Então você é o mandante de tudo isso! O Bicho-Papão em pessoa! Veio assustar o sistema solar errado!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	},
	{
		"nome": "Bicho-Papão",
		"texto": "Eu sou o devorador de estrelas! O fim do seu cordel! A luz da sua nave será a próxima a se apagar.",
		"imagem": preload("res://assets/sprites/enemies/retrato_bicho_papao.jpeg")
	},
	{
		"nome": "Capitão Zé Galáxia",
		"texto": "Meu cordel só termina quando a galáxia estiver a salvo! Engole laser, assombração cibernética!",
		"imagem": preload("res://assets/sprites/player/retrato_ze.png")
	}
]
var indice_dialogo = 0

func _ready():
	gameplay.process_mode = Node.PROCESS_MODE_DISABLED
	caixa_dialogo.visible = false
	
	# Esconde "Ondas" do HUD, pois é uma luta de chefe único
	if hud and hud.has_node("LabelOnda"):
		hud.get_node("LabelOnda").visible = false

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
	if musica_fase:
		musica_fase.stop()
	await get_tree().create_timer(2.0).timeout
	get_tree().paused = true
	var tela_death = cena_game_over.instantiate()
	add_child(tela_death)

func adicionar_pontos(quantidade: int):
	pontuacao += quantidade
	if hud and hud.has_method("atualizar_pontos"):
		hud.atualizar_pontos(pontuacao)

func animar_texto_fase():
	var largura_tela = get_viewport_rect().size.x
	texto_fase.position.x = largura_tela
	texto_fase.position.y = get_viewport_rect().size.y / 2.0 - 50
	var tween = create_tween()
	# Animação mais dramática para o chefe
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

func encerrar_dialogo_e_iniciar_jogo():
	estado_fase = "JOGANDO"
	caixa_dialogo.visible = false
	gameplay.process_mode = Node.PROCESS_MODE_INHERIT
	
	spawnar_bicho_papao()

func spawnar_bicho_papao():
	var boss = cena_boss.instantiate()
	
	# Posiciona o chefe fora da tela para ele descer imponentemente (conforme o script dele)
	var centro_x = get_viewport_rect().size.x / 2.0
	boss.global_position = Vector2(centro_x, -200)
	
	# Quando o Bicho-Papao for derrotado, o jogo entende que voce venceu.
	if boss.has_signal("derrotado"):
		boss.derrotado.connect(vitoria_final)
	
	gameplay.add_child(boss)
	print("Batalha Final Iniciada!")

func vitoria_final():
	if not is_inside_tree():
		return
	if game_over_iniciado: 
		return # Previne chamar vitória se o jogador morrer junto com o chefe
	if estado_fase == "VITORIA":
		return

	estado_fase = "VITORIA"
	
	# Restaura a luz caso o jogador tenha matado o chefe durante o Breu Absoluto
	if canvas_modulate:
		canvas_modulate.color = Color(1, 1, 1, 1)
		
	# Toca uma música de vitória se houver
	if musica_fase:
		musica_fase.stop()
		
	var timer = get_tree().create_timer(3.0)
	await timer.timeout
	if not is_inside_tree():
		return
	get_tree().paused = true
	
	# Carrega a tela de ZERAMENTO do jogo
	var tela_creditos = preload("res://scenes/ui/creditos.tscn").instantiate()
	add_child(tela_creditos)
