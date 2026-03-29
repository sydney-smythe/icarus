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

@export var audio_manager : Node3D
@export var ui_nodes : Control

var active_node_list : Array[Control]  # the node actively being controlled. can be used to restrict key pressed affecting other nodes
var queue_pop : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if queue_pop:
		call_deferred('delayed_pop')

func load_ui(ui_path : String, child_index : int = -1):
	var ui_instance = load(ui_path).instantiate()
	ui_nodes.add_child(ui_instance)
	if child_index != -1:
		ui_nodes.move_child(ui_instance, child_index)

func unload_ui():
	print(str(ui_nodes))
	print(str(ui_nodes.get_child_count()))
	for child in range(0,ui_nodes.get_child_count()):
		ui_nodes.get_child(child).queue_free()

func load_stage_ui(scene_id : String):
	var last_child = ui_nodes.get_child(ui_nodes.get_child_count() - 1)
	unload_ui()
	if last_child:
		await last_child.tree_exited
	call_deferred('load_ui_bundle', scene_id)
	#unload_ui()  # unload the current UI instances
	#await ui_nodes.get_child(get_child_count()-1).tree_exited  # wait for all UI to be unloaded
	#
	#call_deferred('load_ui_bundle', scene_id)  # load the appropriate UI

func load_ui_bundle(scene_id : String):
	var stage_mode = data_manager.stage_dict[scene_id][3]
	if stage_mode == 'PVP':
		for ui_element in ui_bundle_pvp:
			ui_nodes.add_child(load(ui_element).instantiate())
	elif stage_mode == "MAIN MENU":
		for ui_element in ui_bundle_main_menu:
			ui_nodes.add_child(load(ui_element).instantiate())
	elif stage_mode == "CLIMB":
		for ui_element in ui_bundle_climb:
			ui_nodes.add_child(load(ui_element).instantiate())
			
func toggle_end_of_round_screen(player_info_dict : Dictionary):
	var round_end_ui_instance : Control = ui_nodes.get_node('Round End UI')
	if round_end_ui_instance.is_enabled:
		round_end_ui_instance.disable_ui()
	else:
		round_end_ui_instance.enable_ui(player_info_dict)
		
func declare_session_winner(player_id : int):
	ui_nodes.get_node('Round End UI').set_winner(player_id)
	
func toggle_settings():
	if ui_nodes.has_node('Settings UI'):
		ui_nodes.get_node('Settings UI').toggle_visibility()
	else:
		print('[UI Manager] Error: Settings UI is not instantiated.')
		
func enable_climb_result(time : float):
	if ui_nodes.has_node('Climb End Screen'):
		ui_nodes.get_node('Climb End Screen').update_and_enable(time)

func update_and_enable_interact_ui(message : String):
	if ui_nodes.has_node('Interact UI'):
		ui_nodes.get_node('Interact UI').update_and_enable(message)

func disable_interact_ui():
	if ui_nodes.has_node('Interact UI'):
		ui_nodes.get_node('Interact UI').disable_ui()

func play_ui_back_sfx():
	audio_manager.play_back()
	
func play_ui_accept_sfx():
	audio_manager.play_accept()

func add_active_node(node : Control):
	active_node_list.append(node)

func pop_active_node():
	queue_pop = true
	
func delayed_pop():
	queue_pop = false
	if active_node_list.size() > 0:
		active_node_list.remove_at(-1)
	
func get_active_node():
	return active_node_list[-1]

func update_hud_weapons(active_index : int, inventory_array : Array):
	#print('--UI: ' + str(inventory_array))
	# start of round gets called before hud loads so nothing happens, fix (just start of match probably, not start of every round?)
	if ui_nodes.has_node('HUD'):
		ui_nodes.get_node('HUD').update_weapon_info(active_index, inventory_array)
		#print('good :0')
	#print('bad!!!')
	
func update_hud_ammo(active_index : int, ammo : int):
	if ui_nodes.has_node('HUD'):
		ui_nodes.get_node('HUD').update_ammo(active_index, ammo)
