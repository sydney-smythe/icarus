extends Control

@export var default_round_count : int = 5
@export var default_map_id : String = "0"
@export var round_count_label : Label
@export var stage_label : Label

@onready var ui_manager : CanvasLayer = get_parent()
@onready var game_manager : Node3D = get_node("/root/Game Manager")
@onready var data_manager : Node3D = get_node("/root/Game Manager/Sub Managers/Data Manager/")
@onready var stage_manager : Node3D = get_node("/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager/")
var mode_selection_ui : String = "uid://bjfhci57hkl6l"
var round_count  # the number of rounds to pass to game_manager when play is pressed
var stage_info = []
var stage_id : String  # the stage to pass to game_manager when play is pressed
var player_count = 2 # for now, hardcoded at 2

#player_data array stores (for each player: PLAYER ID: [PLAYER NAME, IS_HUMAN_PLAYER]
var players_dict : Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage_id = default_map_id
	round_count = default_round_count
	call_deferred('ui_update')

func ui_update():
	stage_info = data_manager.stage_dict[default_map_id]
	stage_label.text = str(stage_info[1])
	round_count_label.text = ' ' + str(round_count) + ' '


func _on_less_rounds_button_up() -> void:
	if round_count > 3:
		round_count -= 2
		ui_update()


func _on_more_rounds_button_up() -> void:
	if round_count < 255:
		round_count += 2
		ui_update()


func _on_back_button_up() -> void:
	ui_manager.load_ui(mode_selection_ui)
	queue_free()


func _on_start_game_button_up() -> void:
	init_game()
	
	
func init_game():
	# for now, players dict is hard coded
	for player in range(0, player_count):
		players_dict[player] = [('Player ' + str(player)), true]
		#print('Added player: ' + str(players_dict[player]))
	players_dict[1][0] = 'NPC Opponent'
	players_dict[1][1] = false  # hardcode the enemy as an NPC
	
	# load the map
	await stage_manager.load_stage(stage_id)
	print('finished loading the stage')
	
	# send game info to the game manager and tell it to initialize the game
	game_manager.init_pvp_mode(player_count, players_dict, round_count, default_map_id)
	
	# close the UI
	queue_free()
