extends Control

@export var player_info : Array[HBoxContainer]
var pvp_manager : Node3D
@export var best_of_label : Label
@onready var game_manager : Node3D = get_node('/root/Game Manager')
func _ready() -> void:
	self.hide()
	call_deferred('init_scoreboard')

func init_scoreboard():
	pvp_manager = get_node('/root/Game Manager/Sub Managers/PvP Manager/')
	best_of_label.text = 'PvP (Best of ' + str(pvp_manager.rounds) + str(')')
	update_all_players(pvp_manager.player_dict)
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed('scoreboard'):
		if not self.visible:
			self.show()
		update_all_players(pvp_manager.player_dict)
		game_manager.release_mouse()
			
	if Input.is_action_just_released('scoreboard'):
		if self.visible:
			self.hide()
		game_manager.capture_mouse()

func update_all_players(player_info_dict : Dictionary):
	for player in player_info_dict:
		update_player_info(int(player), player_info_dict[player][1], player_info_dict[player][4], player_info_dict[player][5], 0)
#(for each player: PLAYER ID: [NODE, PLAYER NAME, IS_HUMAN_PLAYER, IS_PLAYER_ALIVE, PLAYER WINS, PLAYER DEATHS]

func update_player_info(index : int, player_name : String, wins : int, deaths : int, ping : int):
	player_info[index].get_child(0).text = player_name
	player_info[index].get_child(1).text = str(wins)
	player_info[index].get_child(2).text = str(deaths)
	player_info[index].get_child(3).text = str(ping) + ' ms'
