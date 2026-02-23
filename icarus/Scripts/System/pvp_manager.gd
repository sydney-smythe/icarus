extends Node3D

var rounds = 5
var max_players = 2
var player_count = 0
var stage_id : String
#player_data array stores (for each player: PLAYER ID: [NODE, PLAYER NAME, IS_HUMAN_PLAYER, IS_PLAYER_ALIVE, PLAYER WINS, PLAYER DEATHS]
var player_dict : Dictionary = {}
var enemy_path : String = 'uid://c8x7hvb250pby'
@onready var stage_manager = get_node('/root/Game Manager/SubViewportContainer/SubViewport/Stage Manager')
var stage : Node3D
var is_round_active = false
var alive_players = 2
var current_round = 0
var winner_id : int
var rounds_to_win : int
var time_between_rounds : float = 4.0
var round_start_delay : float = 3.0
@onready var player : CharacterBody3D
@onready var ui_manager = get_node('/root/Game Manager/UI Manager')
@onready var data_manager = get_node('/root/Game Manager/Sub Managers/Data Manager')
@onready var filter_manager : CanvasLayer = get_node('/root/Game Manager/Sub Managers/Filter Manager')
var game_manager : Node3D
# Called when the node enters the scene tree for the first time.

func _ready() -> void:  #initialize the PVP game variables
	call_deferred('late_ready')
	
func late_ready():
	@warning_ignore("integer_division")
	rounds_to_win = rounds - int(rounds/2)
	player = PlayerManager.get_player()
	stage = stage_manager.get_child(0)
	print('player: ' + str(player.name) + ' | stage: ' + str(stage.name))
	game_manager = get_parent().get_parent()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func initialize_session(init_player_count : int, base_players_dict : Dictionary, round_count : int, new_stage_id : String):
	print('[PVP Manager] Starting pvp initialization')
	late_ready()
	stage_id = new_stage_id
	max_players = init_player_count
	player_count = max_players
	rounds = round_count
	initialize_players(base_players_dict)
	print('[PVP Manager] Session initialized successfully.')
	init_round()

func initialize_players(base_players_dict : Dictionary):
	for player_id in base_players_dict:
		player_dict[player_id] = [null, base_players_dict[player_id][0], base_players_dict[player_id][1], true, 0, 0]
		if player_dict[player_id][2]:
			player_dict[player_id][0] = player
				# if player is not human, generate npc
		if not player_dict[player_id][2] and player_dict[player_id][0] == null:
			create_enemy(player_id)
	print('[PVP Manager] Players initialized successfully: ' + str(player_dict))

func create_enemy(player_id : int):
	# create NPC enemy if player is not assigned a node yet
	var enemy = load(enemy_path).instantiate()
	stage.add_child(enemy)
	player_dict[player_id][0] = enemy

func init_round():
	#loads map (if needed), places players
	#1. load map (not applicable rn)
	#2. place players and make them alive
	filter_manager.add_filter('0')
	current_round += 1
	alive_players = player_count
	for player_id in player_dict:
		var player_node = player_dict[player_id][0]
		if player_dict[player_id][2]:
			player_node.disable_freefly()
			player_node.toggle_weapons(false, true)
			player_node.can_move = false
		else:
			player_node.target_mode = false
		player_node.round_reset(data_manager.stage_dict[stage_id][4])
		player_dict[player_id][3] = true  # make players alive
		player_node.global_position = stage.get_node('Spawn Points').assign_random_point(player_count)
		if not player_node.visible:
			player_node.show()
	stage.get_node('Pickup Manager').enable_all_pickups()
	stage_manager.update_enemy_targets()
	await get_tree().create_timer(round_start_delay).timeout
	filter_manager.remove_filter('0')
	for player_id in player_dict:
		var player_node = player_dict[player_id][0]
		if player_dict[player_id][2]:
			player_node.can_move = true
			player_node.toggle_weapons(true, true)
		else:
			player_node.target_mode = true
	is_round_active = true

func end_round():
	# removes players, unloads map (if needed), checks for end of game
	print('[PvP Manager] Round over.')
	is_round_active = false
	var is_winner = false
	# add win for the surviving player(s)
	for player_id in player_dict:
		if player_dict[player_id][3]:  # if alive
			player_dict[player_id][4] += 1
			if player_dict[player_id][4] >= rounds_to_win:
				is_winner = true
				winner_id = player_id
				ui_manager.declare_session_winner(int(player_id))
			if not player_dict[player_id][2]:  # if bot, disable targeting
				player_dict[player_id][0].target_mode = false
	
	print('[PvP Manager] Scores:')
	stage.get_node('Spawn Points').reset_points()
	for player_id in player_dict:
		print(str(player_dict[player_id][1]) + ': ' + str(player_dict[player_id][4]))
	print('')
	ui_manager.toggle_end_of_round_screen(player_dict)
	await get_tree().create_timer(time_between_rounds).timeout
	ui_manager.toggle_end_of_round_screen(player_dict)
	if is_winner:
		end_session()
	else:
		if current_round == rounds:
			end_session()
		else:
			init_round()

func kill_player(player_node : CharacterBody3D):
	for player_id in player_dict:
		if player_dict[player_id][0] == player_node:
			player_dict[player_id][3] = false
			player_dict[player_id][5] += 1
			alive_players -= 1
			
			# for now, hide the enemy
			if player_dict[player_id][2] == false:
				player_node.hide()
				player_node.target_mode = false
			else:
				player_node.enable_freefly()
				player_node.toggle_weapons(false)
	if alive_players <= 1:
		end_round()

func end_session():
	# ends the game
	print('[PvP Manager] Session ended. Winner: ' + str(player_dict[winner_id][1]))
	#stage = null
	game_manager.quit_to_main_menu()
	#load_stage(stage_id : String, enable_player : bool = true, auto_mouse_capture : bool = true):
	
