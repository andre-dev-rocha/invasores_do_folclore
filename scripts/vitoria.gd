extends CanvasLayer

func _on_btn_continuar_pressed():
	get_tree().paused = false # Despausa o mundo
	# Leva para a história antes da fase 2
	get_tree().change_scene_to_file("res://scenes/ui/loja_upgrades.tscn")
