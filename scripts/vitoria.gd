extends CanvasLayer
class_name Vitoria

static var proxima_cena: String = "res://scenes/ui/loja_upgrades.tscn"

func _ready():
	$SomVitoria.play()


func _on_btn_continuar_pressed():
	get_tree().paused = false
	var cena = proxima_cena
	proxima_cena = "res://scenes/ui/loja_upgrades.tscn"
	get_tree().change_scene_to_file(cena)
