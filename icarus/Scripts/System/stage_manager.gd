extends Node3D

@onready var player = %Player
@onready var data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/") 
@onready var game_manager: Node3D = $".."
@onready var ui_manager: Control = $"../UI Manager"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred('late_ready')

func late_ready():
	load_stage('-1', false, false)
	update_enemy_targets()

func update_enemy_targets():
	get_tree().call_group('Enemies', 'set_target', player)
	
func load_stage(stage_id : String, enable_player : bool = true, auto_mouse_capture : bool = true):
	var stage = load(data_manager.stage_dict[stage_id][0]).instantiate()
	self.add_child(stage)
	if get_child_count() > 1:
		move_child(stage, 0)
		get_child(1).queue_free()  # remove default stage
	
	if enable_player:
		game_manager.enable_player()
	else:
		game_manager.disable_player()
	ui_manager.load_stage_ui(stage_id)
	update_enemy_targets()
	var default_weapon : String = data_manager.stage_dict[stage_id][4]
	if default_weapon != 'null':
		player.equipment_manager.add_equipment(0, default_weapon, true, true)
	if auto_mouse_capture:
		game_manager.capture_mouse()
	else:
		game_manager.release_mouse()
	print('[Stage Manager] finished loading stage: ' + str(stage.name))
	#func add_equipment(equipment_index : int, equipment_id : String, can_equip : bool = true, is_auto_active : bool = false, auto_assign_index = false):
	
func unload_stage():
	pass
	
func load_main_menu(menu_ui_stage : String = 'Main Menu'):
	load_stage('-1', false, false)
	# tell UI manager to load specific main menu ui stage
	
