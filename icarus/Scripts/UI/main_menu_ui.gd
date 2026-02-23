extends Control

@onready var game_manager: Node3D = get_node('/root/Game Manager')
@onready var stage_manager: Node3D = get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager/')
@onready var ui_manager : CanvasLayer = get_parent().get_parent()
var stage_selection_ui = "uid://bjfhci57hkl6l" 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_mode_selection_ui():
	ui_manager.load_ui(stage_selection_ui)
	queue_free()

func load_stage(stage_id : String = '0') -> void:
	stage_manager.load_stage(stage_id)
	queue_free()


func _on_play_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	load_mode_selection_ui()


func _on_settings_button_up() -> void:
	ui_manager.play_ui_accept_sfx()
	ui_manager.toggle_settings()
