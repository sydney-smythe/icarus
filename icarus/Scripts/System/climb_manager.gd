extends Node3D

var climb_timer = 0
var stage_id : String
var active_session : bool = false
var end_of_climb_timer : float = 5.0
@onready var ui_manager = get_node('/root/Game Manager/UI Manager/')
@onready var game_manager = get_node('/root/Game Manager')
@onready var data_manager = get_node('/root/Game Manager/Sub Managers/Data Manager')
var player : CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PlayerManager.get_player()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active_session:
		climb_timer += delta

func initialize_session(stage_id : String):
	var raw_pos_data = data_manager.stage_dict[stage_id][2]
	player.global_position = Vector3(raw_pos_data[0], raw_pos_data[1], raw_pos_data[2])
	active_session = true
	

func end_session(end_mode : String):
	active_session = false
	if end_mode == 'Win':
		game_manager.can_pause = false
		ui_manager.enable_climb_result(climb_timer)
		await get_tree().create_timer(end_of_climb_timer).timeout
		game_manager.can_pause = true
	
	game_manager.quit_to_main_menu()
