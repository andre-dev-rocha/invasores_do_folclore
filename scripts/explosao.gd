extends AnimatedSprite2D

func _on_animation_finished():
	# Quando o fogo da explosão sumir, removemos o nó da memória
	queue_free()
