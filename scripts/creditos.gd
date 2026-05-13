extends Control

@export var scroll_speed := 90.0
@export var start_offset := 40.0

@onready var credits_container: VBoxContainer = $CreditsContainer

var _is_exiting := false

func _ready():
	call_deferred("_reset_position")

func _process(delta):
	if _is_exiting:
		return
	credits_container.position.y -= scroll_speed * delta
	if credits_container.position.y + credits_container.size.y < 0.0:
		_return_to_menu()

func _unhandled_input(event):
	if _is_exiting:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_return_to_menu()

func _reset_position():
	var viewport_height := get_viewport_rect().size.y
	credits_container.position.y = viewport_height + start_offset

func _return_to_menu():
	if _is_exiting:
		return
	_is_exiting = true
	get_tree().change_scene_to_file("res://scenes/ui/menu_principal.tscn")