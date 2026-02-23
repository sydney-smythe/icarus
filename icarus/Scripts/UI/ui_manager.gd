extends CanvasLayer

@onready var data_manager: Node3D = $"../Sub Managers/Data Manager"

var debug_ui = 'uid://c740upcymk5ps'
var crosshair = 'uid://dw1b0eqcs74nf'
var hud = 'uid://hl5qyawevdr'
var main_menu = 'uid://c6oaxjuj06mpc'
var scoreboard = 'uid://t5kh5t0i2mfv'
var round_end_ui = 'uid://by2of4wml06rx'
var pause_menu_ui = 'uid://d2rrdcquv1ekb'
var interact_ui = 'uid://bsw8stde55cuu'
var settings_ui = 'uid://dhto1yiiq25hm'
var climb_end_screen = 'uid://dka3ko6oqq5qv'

var ui_bundle_main_menu : Array[String] = [debug_ui, main_menu, settings_ui]
var ui_bundle_pvp : Array[String] = [debug_ui, crosshair, hud, scoreboard, round_end_ui, pause_menu_ui, interact_ui, settings_ui]
var ui_bundle_climb : Array[String] = [debug_ui, crosshair, hud, pause_menu_ui, interact_ui, settings_ui, climb_end_screen]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func load_ui(ui_path : String):
	var ui_instance = load(ui_path).instantiate()
	add_child(ui_instance)

func unload_ui():
	for child in range(0,get_child_count()):
		get_child(child).queue_free()

func load_stage_ui(scene_id : String):
	
	unload_ui()  # unload the current UI instances
	await get_child(get_child_count()-1).tree_exited  # wait for all UI to be unloaded
	
	call_deferred('load_ui_bundle', scene_id)  # load the appropriate UI

func load_ui_bundle(scene_id : String):
	var stage_mode = data_manager.stage_dict[scene_id][3]
	if stage_mode == 'PVP':
		for ui_element in ui_bundle_pvp:
			add_child(load(ui_element).instantiate())
	elif stage_mode == "MAIN MENU":
		for ui_element in ui_bundle_main_menu:
			add_child(load(ui_element).instantiate())
	elif stage_mode == "CLIMB":
		for ui_element in ui_bundle_climb:
			add_child(load(ui_element).instantiate())
			
func toggle_end_of_round_screen(player_info_dict : Dictionary):
	var round_end_ui_instance : Control = get_node('Round End UI')
	if round_end_ui_instance.is_enabled:
		round_end_ui_instance.disable_ui()
	else:
		round_end_ui_instance.enable_ui(player_info_dict)
		
func declare_session_winner(player_id : int):
	get_node('Round End UI').set_winner(player_id)
	
func toggle_settings():
	if has_node('Settings UI'):
		get_node('Settings UI').toggle_visibility()
	else:
		print('[UI Manager] Error: Settings UI is not instantiated.')
		
func enable_climb_result(time : float):
	if has_node('Climb End Screen'):
		get_node('Climb End Screen').update_and_enable(time)
