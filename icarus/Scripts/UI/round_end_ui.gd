extends Control

@export var player_names : Array[Label]
@export var player_scores : Array[Label]
@export var winner_labels : Array[Label]
var is_enabled = false
var winner : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	for label in winner_labels:
		label.text = ''

func enable_ui(player_info : Dictionary):
	for player in player_info:
		update_player_info(int(player), player_info[player][1], player_info[player][4])
	if not self.visible:
		self.show()
	is_enabled = true

func disable_ui():
	if self.visible:
		self.hide()
	is_enabled = false

func update_player_info(index : int, player_name : String, wins : int):
	player_names[index].text = player_name
	player_scores[index].text = str(wins)

func set_winner(index : int):
	winner_labels[index].text = 'Winner!'
