extends Control

@onready var ui_manager = get_parent().get_parent()
@onready var stage_manager = get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager')
@onready var game_manager = get_node('/root/Game Manager')
var main_menu_ui = "uid://c6oaxjuj06mpc"
var pvp_lobby_ui = "uid://uvne644wrm3k"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_climb_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	stage_manager.load_stage("1")
	game_manager.init_climb_mode("1")

func _on_pv_p_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	ui_manager.load_ui(pvp_lobby_ui)
	queue_free()


func _on_back_button_up() -> void:
	ui_manager.play_ui_back_sfx()
	ui_manager.load_ui(main_menu_ui)
	queue_free()
