extends Node3D

@onready var player = %Player
var pvp_manager = "uid://cemuhifmaw5q3"
var active_mode = 'UI' # OPTIONS: UI, PVP, CLIMB
@onready var sub_managers = get_node('Sub Managers')
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	disable_player()
	
func disable_player():
	player.player_enabled = false
	player.equipment_manager.disable_equipment()
	
func enable_player():
	player.player_enabled = true
	player.equipment_manager.enable_equipment()
	
func init_pvp_mode(player_count : int, player_list : Dictionary, round_count : int):
	var pvp_mode = load(pvp_manager).instantiate()
	sub_managers.add_child(pvp_mode)
	pvp_mode.initialize_session(player_count, player_list, round_count)
	active_mode = 'PVP'

func signal_killed(node : CharacterBody3D):
	if active_mode == 'PVP':
		sub_managers.get_node('PvP Manager').kill_player(node)
