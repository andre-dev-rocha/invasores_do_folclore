extends Area2D

@export var velocidade : float = 300.0

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	

	area_entered.connect(_on_impacto)
	body_entered.connect(_on_impacto)

func _process(delta):
	position.y += velocidade * delta

func _on_impacto(objeto):
	if objeto.is_in_group("player") or objeto.name == "EscudoArea":
	
		var player = objeto
		if objeto.name == "EscudoArea":
			player = objeto.get_parent()
		
		if player.has_method("receber_dano"):
			player.receber_dano()
		
		queue_free()
