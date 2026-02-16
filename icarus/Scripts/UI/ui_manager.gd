extends Control

@onready var data_manager: Node3D = $"../Sub Managers/Data Manager"

var crosshair = 'uid://dw1b0eqcs74nf'
var hud = 'uid://hl5qyawevdr'
var main_menu = 'uid://c6oaxjuj06mpc'
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_ui(ui_path : String):
	var ui_instance = load(ui_path).instantiate()
	add_child(ui_instance)

func load_stage_ui(scene_id : String):
	var stage_mode = data_manager.stage_dict[scene_id][3]
	
	if stage_mode == 'PVP':
		add_child(load(crosshair).instantiate())
		add_child(load(hud).instantiate())
	elif stage_mode == "MAIN MENU":
		add_child(load(main_menu).instantiate())
