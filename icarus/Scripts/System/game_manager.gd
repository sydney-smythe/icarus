extends Node3D

# GAME INFORMATION
const GAME_VERSION : String = '0.2.314'
const GAME_BUILD : String = '002'
const GAME_STATE : String = 'Pre-Alpha'
const GAME_PLAYTEST_NAME : String = '02-Milan'

@onready var player = %Player
var pvp_manager = "uid://cemuhifmaw5q3"
var climb_manager = "uid://cx7i1y6oxaq6s"
var active_mode = 'UI' # OPTIONS: UI, PVP, CLIMB
var mouse_captured = false
var is_paused = false
var can_pause = true
@onready var sub_managers = get_node('Sub Managers')
@onready var stage_manager = get_node('SubViewportContainer/SubViewport/Stage Manager/')
@onready var filter_manager = get_node('Sub Managers/Filter Manager')
@onready var subviewport = get_node('SubViewportContainer/SubViewport')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_player()
	
func disable_player():
	player.player_enabled = false
	player.equipment_manager.disable_equipment()
	
func enable_player():
	player.player_enabled = true
	player.equipment_manager.enable_equipment()

func quit_to_main_menu():
	if active_mode == 'PVP':
		sub_managers.get_node('PvP Manager').queue_free()
		filter_manager.remove_filter('0')
		
	if active_mode == 'CLIMB':
		sub_managers.get_node('Climb Manager').queue_free()
	
	is_paused = false
	active_mode = 'UI'
	stage_manager.load_stage('-1', false, false)
	
func init_pvp_mode(player_count : int, player_list : Dictionary, round_count : int, starting_stage_id : String):
	var pvp_mode = load(pvp_manager).instantiate()
	sub_managers.add_child(pvp_mode)
	pvp_mode.initialize_session(player_count, player_list, round_count, starting_stage_id)
	active_mode = 'PVP'
	
func init_climb_mode(stage_id : String):
	var climb_mode = load(climb_manager).instantiate()
	sub_managers.add_child(climb_mode)
	active_mode = 'CLIMB'
	climb_mode.initialize_session(stage_id)

func signal_killed(node : CharacterBody3D):
	if active_mode == 'PVP':
		sub_managers.get_node('PvP Manager').kill_player(node)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func _unhandled_input(event: InputEvent) -> void:
	subviewport.push_input(event)
