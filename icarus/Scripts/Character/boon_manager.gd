extends Node3D

var active_boons : Dictionary = {}
var data_manager
var boon_dict : Dictionary
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data_manager = get_node("/root/Game Manager/Sub Managers/Data Manager/")
	boon_dict = data_manager.boon_dict

func apply_boon(boon_id : String, length : float = 30.0):
	# test if boon is already on player
	var boon_index : int = -1
	for child_index in range(0,get_child_count()):
		var child = get_child(child_index)
		if child.boon_id == boon_id:
			boon_index = child_index
			break
	if boon_index == -1:  # spawn new boon
		var new_boon = load(boon_dict[boon_id][0]).instantiate()
		new_boon.boon_timer = length
		add_child(new_boon)
		print('[Boon Manager] Applied boon: ' + boon_dict[boon_id][1] + ' for ' + str(length) + 's')
	else:  # reset boon timer
		get_child(boon_index).boon_timer = length
		print('[Boon Manager] Updated boon: ' + boon_dict[boon_id][1] + ' for ' + str(length) + 's')
		
func clear_boons():
	for child_index in range(0,get_child_count()):
		get_child(child_index).update_timer(0, true)
