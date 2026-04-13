extends Node2D 

@export var tempo_animacao: float = 1.0 # Tempo que ele leva para sumir
@export var distancia_subida: float = 60.0 # Quantos pixels ele sobe

func _ready():

	var tween = create_tween()
	

	tween.tween_property(self, "position:y", position.y - distancia_subida, tempo_animacao)
	

	tween.parallel().tween_property(self, "modulate:a", 0.0, tempo_animacao)
	

	tween.finished.connect(queue_free)
